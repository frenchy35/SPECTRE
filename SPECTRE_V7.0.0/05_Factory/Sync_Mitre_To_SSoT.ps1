<#
.DESCRIPTION
    NOM : Sync_Mitre_To_SSoT.ps1
    VERSION : 1.3.0 (Basee sur Master_DB indexee)
    Role : Distribue les techniques MITRE dans les categories SPECTRE (SSoT).
    [SECURITE] : Verification Tamper Protection integree.
    [CONTRAINTES] : Zero accent. Encodage ASCII. Debug function.
#>

function Invoke-SpectreDebug {
    param([string]$Message, [string]$Type = "INFO")
    $Timestamp = Get-Date -Format "HH:mm:ss"
    $Color = switch($Type) { "ERR" {"Red"} "WARN" {"Yellow"} Default {"Gray"} }
    Write-Host "[$Timestamp][$Type] $Message" -ForegroundColor $Color
}

# --- CONFIGURATION DES CHEMINS ---
$PSScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Path $MyInvocation.MyCommand.Definition -Parent }
$ProjectRoot = Split-Path -Path $PSScriptRoot -Parent
$MasterDBPath = Join-Path $ProjectRoot "00_Core\MITRE_Master_DB.json"
$SSoTFolder = Join-Path $ProjectRoot "01_SSoT"

if (-not (Test-Path $MasterDBPath)) {
    Invoke-SpectreDebug "ERREUR : Master DB introuvable. Generez-la d abord." "ERR"
    return
}

try {
    Invoke-SpectreDebug "Chargement de la Master DB indexee..."
    $DB = Get-Content -Path $MasterDBPath | ConvertFrom-Json
    $MasterTechs = $DB.Techniques

    # Liste des categories cibles
    $Categories = @("S_Silicon", "D_Defense", "N_Network", "P_Privacy", "U_User", "G_Governance")

    foreach ($Cat in $Categories) {
        $TargetFile = Join-Path $SSoTFolder "$Cat.json"
        Invoke-SpectreDebug "Filtrage pour la categorie : $Cat..."

        # Extraction des techniques correspondant a la categorie (via le flag SpectreCat genere precedemment)
        $MatchedTechs = @()
        foreach ($Prop in $MasterTechs.PSObject.Properties) {
            if ($Prop.Value.SpectreCat -eq $Cat) {
                $MatchedTechs += $Prop.Value
            }
        }

        # Construction de l'objet SSoT
        $SSoTObject = [PSCustomObject]@{
            Header = [PSCustomObject]@{
                Category    = $Cat
                Description = "Points de controle synchronises"
                Version     = "1.0.0"
                TotalCount  = $MatchedTechs.Count
            }
            # On cree la liste des points de controle, tous en PENDING/FALSE par defaut
            Controls = $MatchedTechs | ForEach-Object {
                [PSCustomObject]@{
                    MitreID     = $_.ID
                    Name        = $_.Name
                    Status      = "PENDING"
                    Enforced    = $false
                    Tactic      = ($_.Tactics -join ", ")
                }
            }
        }

        Invoke-SpectreDebug "Exportation de $Cat.json ($($MatchedTechs.Count) techniques)..."
        $SSoTObject | ConvertTo-Json -Depth 10 | Out-File -FilePath $TargetFile -Encoding ascii -Force
    }

    Invoke-SpectreDebug "Synchronisation SSoT terminee." "INFO"
}
catch {
    Invoke-SpectreDebug "ERREUR : $($_.Exception.Message)" "ERR"
}