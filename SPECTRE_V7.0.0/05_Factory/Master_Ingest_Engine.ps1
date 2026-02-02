<#
.DESCRIPTION
    NOM : Master_Ingest_Engine.ps1 | VERSION : 11.0
    ARCHITECTURE : SPECTRE V7.1.2 (ISO-13)
    OBJECTIF : Ingestion massive des Atomics ART vers l'Atlas JSON.
    
    LISTE DES OBJECTIFS OPERATIONNELS :
    1. OBJECTIF DE DECOUVERTE : Scan exhaustif du dossier ART_REPO.
    2. OBJECTIF DE FILTRAGE : Selection stricte des plateformes Windows.
    3. OBJECTIF DE PORTABILITE : Neutralisation automatique des profils (LGE).
    
    LISTE DES OBLIGATIONS ET DIRECTIVES :
    (Conforme aux 15 directives de developpement SPECTRE).
#>

# --- 1. ANCRAGE ET CHEMINS ---
$CurrentDir = $PSScriptRoot
if (-not $CurrentDir) { $CurrentDir = Get-Location }
$ProjectRoot = $CurrentDir
while (-not (Test-Path (Join-Path $ProjectRoot "00_Core")) -and $ProjectRoot -ne (Split-Path $ProjectRoot -Qualifiers)) {
    $ProjectRoot = Split-Path $ProjectRoot -Parent
}

$ArtPath   = Join-Path $ProjectRoot "01_Source_Data\ART_REPO\atomics"
$DestAtlas = Join-Path $ProjectRoot "00_Core\Hybrid_ART_MITRE_Atlas.json"

function Out-Ingest { param($M, $L="INFO") $C = switch($L){"SUCCESS"{"Green"}"ERR"{"Red"}Default{"Gray"}}; Write-Host "[INGEST] $M" -ForegroundColor $C }

if (-not (Test-Path $ArtPath)) { Out-Ingest "Dossier ART introuvable : $ArtPath" "ERR"; return }

# --- 2. LOGIQUE DE NEUTRALISATION (DIRECTIVE 14) ---
function Set-NeutralPath {
    param($Path)
    if ($null -eq $Path) { return "" }
    # Remplacement des ancres utilisateur par des variables systeme pour portabilite
    return $Path -replace 'C:\\Users\\[^\\]+', '$env:USERPROFILE'
}

# --- 3. SCAN ET EXTRACTION ---
$Atlas = @{ "Metadata"=@{"GenDate"=$(Get-Date -Format "G"); "Engine" = "SPECTRE_V11"}; "Techniques"=@{} }
$Atomics = Get-ChildItem $ArtPath -Filter "*.yaml" -Recurse

Out-Ingest "Debut de l ingestion de $($Atomics.Count) fichiers YAML..."

foreach ($File in $Atomics) {
    try {
        $Content = Get-Content $File.FullName -Raw
        $TID = $File.Directory.Name # Dossier type T1547.001
        
        # Extraction basique via Regex pour eviter la lenteur des parseurs YAML sur 1000 fichiers
        if ($Content -match "supported_platforms:.*windows") {
            
            $Actions = New-Object System.Collections.Generic.List[object]

            # Extraction des cles de registre
            [regex]::Matches($Content, '(?i)(HKLM|HKCU):\\[a-z0-9\\\-_ ]+.*?-Name\s+"?([a-z0-9_\-]+)"?\s+-Value\s+([^\s\r\n]+)') | ForEach-Object {
                $Path = Set-NeutralPath $_.Groups[1].Value + $_.Groups[0].Value.Split("-Name")[0].Split(":")[1]
                $Actions.Add(@{
                    "T"     = "Registry"
                    "Path"  = Set-NeutralPath ($_.Groups[1].Value + ":" + ($_.Value -split ":")[1].Split("-Name")[0].Trim())
                    "Key"   = $_.Groups[2].Value.Trim()
                    "Value" = Set-NeutralPath $_.Groups[3].Value.Trim().Replace('"', '').Replace("'", "")
                })
            }

            # Extraction des fichiers
            [regex]::Matches($Content, '(?i)(New-Item|Copy-Item|Out-File).*?-Path\s+"?([^"\s\r\n]+)"?') | ForEach-Object {
                $Actions.Add(@{
                    "T"    = "File"
                    "Path" = Set-NeutralPath $_.Groups[2].Value.Trim()
                    "Key"  = "Artefact"
                })
            }

            if ($Actions.Count -gt 0) {
                $Atlas.Techniques[$TID] = @{
                    "ID"       = $TID
                    "Cloaking" = $Actions
                    "Analysis" = @{ "Furtivite_Score" = $Actions.Count }
                }
            }
        }
    } catch {
        Out-Ingest "Erreur sur $($File.Name)" "ERR"
    }
}

# --- 4. SAUVEGARDE SSoT ---
$Atlas | ConvertTo-Json -Depth 10 | Out-File $DestAtlas -Encoding ascii -Force
Out-Ingest "Atlas finalise avec $($Atlas.Techniques.Count) techniques Windows." "SUCCESS"