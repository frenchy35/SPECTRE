<#
.DESCRIPTION
    NOM : Fetch_Mitre_Online.ps1
    VERSION : 1.0.2
    [SECURITE] : Verification de marqueur de racine pour eviter la pollution.
    Recupere les techniques Enterprise ATT&CK.
    [CONTRAINTES] : Zero accent. Encodage ASCII. Debug function.
#>

# --- INTEGRATION FONCTION DEBUG (CONSIGNE) ---
function Invoke-SpectreDebug {
    param([string]$Message, [string]$Type = "INFO")
    $Color = switch($Type) { "ERR" {"Red"} "WARN" {"Yellow"} Default {"Gray"} }
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')][$Type] $Message" -ForegroundColor $Color
}

# --- DETECTION SECURISEE DE LA RACINE ---
$Current = $PSScriptRoot
$ProjectRoot = $null

while ($Current -ne (Split-Path $Current -Parent)) {
    # On cherche un marqueur unique de votre projet V7
    if (Test-Path (Join-Path $Current "bootstrap_v7.ps1")) {
        $ProjectRoot = $Current
        break
    }
    $Current = Split-Path $Current -Parent
}

# Blocage de securite
if ($null -eq $ProjectRoot) {
    Invoke-SpectreDebug "ERREUR : Racine SPECTRE introuvable. Operation annulee pour eviter la pollution." "ERR"
    return
}

$MasterDBPath = Join-Path $ProjectRoot "00_Core\MITRE_Master_DB.json"
$MitreSourceUrl = "https://raw.githubusercontent.com/mitre/cti/master/enterprise-attack/enterprise-attack.json"

Invoke-SpectreDebug "Racine validee : $ProjectRoot"
Invoke-SpectreDebug "Cible : $MasterDBPath"

try {
    Invoke-SpectreDebug "Connexion au depot MITRE (GitHub CTI)..."
    $Response = Invoke-RestMethod -Uri $MitreSourceUrl -Method Get
    $Objects = $Response.objects | Where-Object { $_.type -eq "attack-pattern" -and $_.external_references.external_id -match "^T\d" }

    Invoke-SpectreDebug "$($Objects.Count) techniques recuperees."

    $TechniquesList = [System.Collections.Generic.List[object]]::new()
    foreach ($Obj in $Objects) {
        $ExtRef = $Obj.external_references | Where-Object { $_.source_name -eq "mitre-attack" }
        $Entry = [PSCustomObject]@{
            MitreID = $ExtRef.external_id
            Name    = $Obj.name
            Tactics = $Obj.kill_chain_phases.phase_name
            URL     = $ExtRef.url
        }
        $TechniquesList.Add($Entry)
    }

    $MasterDB = [PSCustomObject]@{
        Framework = "SPECTRE_V7"
        LastSync  = (Get-Date -Format "yyyy-MM-dd HH:mm")
        Source    = "MITRE CTI GitHub"
        Techniques = $TechniquesList | Sort-Object MitreID
    }

    $MasterDB | ConvertTo-Json -Depth 10 | Out-File -FilePath $MasterDBPath -Encoding ascii -Force
    Invoke-SpectreDebug "Synchronisation reussie." "INFO"

} catch {
    Invoke-SpectreDebug "Echec : $($_.Exception.Message)" "ERR"
}