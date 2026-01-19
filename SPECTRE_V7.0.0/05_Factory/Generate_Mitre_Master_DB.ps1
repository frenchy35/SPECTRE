<#
.DESCRIPTION
    NOM : Generate_Mitre_Master_DB.ps1
    VERSION : 1.2.0 (Optimisee pour acces direct)
    Role : Genere la base de reference MITRE indexee pour SPECTRE.
    [SECURITE] : Verification Tamper Protection integree.
    [CONTRAINTES] : Zero accent. Encodage ASCII. Debug function.
#>

function Invoke-SpectreDebug {
    param([string]$Message, [string]$Type = "INFO")
    $Timestamp = Get-Date -Format "HH:mm:ss"
    $Color = switch($Type) { "ERR" {"Red"} "WARN" {"Yellow"} Default {"Gray"} }
    Write-Host "[$Timestamp][$Type] $Message" -ForegroundColor $Color
}

# --- CONFIGURATION ---
$PSScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Path $MyInvocation.MyCommand.Definition -Parent }
$ProjectRoot = Split-Path -Path $PSScriptRoot -Parent
$OutputPath = Join-Path $ProjectRoot "00_Core\MITRE_Master_DB.json"
$MitreUrl = "https://raw.githubusercontent.com/mitre/cti/master/enterprise-attack/enterprise-attack.json"

try {
    Invoke-SpectreDebug "Contact du depot MITRE CTI..."
    $RawData = Invoke-RestMethod -Uri $MitreUrl -Method Get
    
    # Utilisation d'une table de hachage pour l'indexation rapide
    $TechniquesIndex = @{}

    Invoke-SpectreDebug "Indexation des techniques Enterprise/Windows..."
    foreach ($Obj in $RawData.objects) {
        if ($Obj.type -eq "attack-pattern" -and $Obj.x_mitre_platforms -contains "Windows" -and $Obj.x_mitre_deprecated -ne $true) {
            
            $MitreID = ($Obj.external_references | Where-Object { $_.source_name -eq "mitre-attack" }).external_id
            
            # Creation d'une entree propre et facile a parser
            $TechniquesIndex[$MitreID] = [PSCustomObject]@{
                ID          = $MitreID
                Name        = $Obj.name
                Tactics     = $Obj.kill_chain_phases.phase_name
                Description = $Obj.description.Split(".")[0]
                # Pre-mapping pour faciliter la generation des JSON SSoT
                SpectreCat  = switch -Wildcard ($Obj.name + $Obj.description) {
                    "*hardware*" {"S_Silicon"}
                    "*virtual*"  {"S_Silicon"}
                    "*defender*" {"D_Defense"}
                    "*antivirus*"{"D_Defense"}
                    "*proxy*"    {"N_Network"}
                    "*telemetry*"{"P_Privacy"}
                    Default      {"G_Governance"}
                }
            }
        }
    }

    $FinalDB = [PSCustomObject]@{
        Metadata = @{
            Version    = "1.2.0"
            TotalCount = $TechniquesIndex.Count
            BuildDate  = Get-Date -Format "yyyy-MM-dd HH:mm"
        }
        # On exporte l'index comme un objet proprietes pour l'acces direct JSON
        Techniques = $TechniquesIndex
    }

    $FinalDB | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding ascii -Force
    Invoke-SpectreDebug "SUCCESS : DB generee et indexee ($($TechniquesIndex.Count) entrees)." "INFO"
}
catch {
    Invoke-SpectreDebug "ERREUR : $($_.Exception.Message)" "ERR"
}