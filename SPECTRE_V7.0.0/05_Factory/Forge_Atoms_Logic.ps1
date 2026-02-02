<#
.DESCRIPTION
    NOM : Forge_Atoms_Logic.ps1 | VERSION : 7.0
    OBJECTIF : Génération d'Atomes avec Aide (--help) et Obligations SPECTRE.
#>

$AtlasPath = ".\00_Core\Hybrid_ART_MITRE_Atlas.json"
$AtomsDir  = ".\02_Atoms"

function Out-Forge { param($M, $L="INFO") $C = if($L -eq "SUCCESS"){"Green"}else{"Gray"}; Write-Host "[FORGE][$L] $M" -ForegroundColor $C }

$Atlas = Get-Content $AtlasPath -Raw | ConvertFrom-Json

foreach ($TechID in $Atlas.Techniques.PSObject.Properties.Name) {
    $SafeActions = $Atlas.Techniques.$TechID.Actions | ConvertTo-Json -Compress

    $Template = @'
# --- ATOME SPECTRE : {TECH_ID} ---
# Version : 7.0.0 | Architecture Core V6.9

$CorePath = Join-Path $PSScriptRoot "..\00_Core\Spectre_Core_Logic.psm1"
if (Test-Path $CorePath) { Import-Module $CorePath -Force } else { Write-Error "Core non trouve"; exit }

$Targets = '{JSON_DATA}' | ConvertFrom-Json

# --- DISPATCHER DE COMMANDES ---
if ($args -contains "--audit") { Invoke-SpectreAudit -Targets $Targets -TechID "{TECH_ID}" }
elseif ($args -contains "--commit") { Invoke-SpectreCommit -Targets $Targets -TechID "{TECH_ID}"; Invoke-SpectreAudit -Targets $Targets -TechID "{TECH_ID}" }
elseif ($args -contains "--rollback") { Invoke-SpectreRollback -Targets $Targets -TechID "{TECH_ID}"; Invoke-SpectreAudit -Targets $Targets -TechID "{TECH_ID}" }
elseif ($args -contains "--help") {
    Write-Host "`n--- AIDE ATOME SPECTRE : {TECH_ID} ---" -ForegroundColor Cyan
    Write-Host "CONTEXTE : Hybrid ART/MITRE Registry & Services Audit"
    Write-Host "`nMODES DISPONIBLES :"
    Write-Host "  --audit    : Analyse les ecarts sans modifier le systeme."
    Write-Host "  --commit   : Aligne le systeme sur le referentiel Atlas (Sabotage)."
    Write-Host "  --rollback : Restaure l'etat initial (Nettoyage)."
    Write-Host "`nOBLIGATIONS & CONTRAINTES (DOCTRINE 2026-01-20) :" -ForegroundColor Yellow
    Write-Host "  1. VERBOSITE TOTALE : Chaque action est loguee en temps reel."
    Write-Host "  2. ZERO INVENTION  : Seules les valeurs de l'Atlas sont appliquees."
    Write-Host "  3. AUDIT PAR CIBLE : Rapport d'ecart granulaire obligatoire."
    Write-Host "  4. REVERSIBILITE   : Rollback obligatoire pour chaque commit."
    Write-Host ""
}
else { Out-Spectre "Usage: .\$($MyInvocation.MyCommand.Name) --help" "WARN" "{TECH_ID}" }
'@

    $FinalScript = $Template.Replace("{TECH_ID}", $TechID).Replace("{JSON_DATA}", $SafeActions)
    $Path = Join-Path $AtomsDir "$TechID.ps1"
    $FinalScript | Out-File $Path -Encoding utf8 -Force
    Out-Forge "Atome $TechID forge avec documentation (--help)." "SUCCESS"
}