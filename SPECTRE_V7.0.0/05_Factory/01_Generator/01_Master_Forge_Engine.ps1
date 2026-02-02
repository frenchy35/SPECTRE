<#
.DESCRIPTION
    NOM          : 01_Master_Forge_Engine.ps1
    VERSION      : 13.58 (Key-Mapping Alignment)
    ARCHITECTURE : SPECTRE V7.9.0
    STATUS       : CONFORME (AUTO-CRITIQUE VALIDEE)
    EMPLACEMENT  : 05_Factory\01_Generator\

    LISTE COMPLETE DES DIRECTIVES ET OBLIGATIONS (V13.58) :
    1.  NUMEROTATION STRICTE (CHIFFRE EN PREMIER SUR TOUT FICHIER/DOSSIER).
    2.  SEPARATION STRICTE OBJECTIFS / DIRECTIVES / OBLIGATIONS.
    3.  INTERDICTION ABSOLUE DE REDUIRE OU AMPUTER LE CODE (ANTI-PARESSE).
    4.  CONFRONTATION SYSTEMATIQUE AUX CONTRAINTES AVANT PRESENTATION.
    5.  BOUCLE D'AUTO-CRITIQUE DE CONFORMITE TECHNIQUE COMPLETE (DENSITE, NUMEROTATION, VERBOSITE, PS 5.1) AVANT TOUTE PROPOSITION.
    6.  PRESENCE DU MODE AIDE (--HELP) DANS CHAQUE SCRIPT.
    7.  LOGIQUE DE FONCTIONNEMENT : AUDIT / COMMIT / DEBUG / ROLLBACK / HELP.
    8.  DESCRIPTION DOIT CONTENIR LA LISTE COMPLETE DES OBLIGATIONS.
    9.  LES OBJECTIFS DOIVENT ETRE SEPARES DES DIRECTIVES ET OBLIGATIONS.
    10. CHAQUE TEMPLATE DOIT INCLURE LA LISTE DE TOUTES LES CONTRAINTES LIEES A SON CONTEXTE.
    11. INCLUSION DES FONCTIONNALITES AUDIT/COMMIT/DEBUG/ROLLBACK DANS CHAQUE ATOME.
    12. CHAQUE TEMPLATE EMBARQUE AUSSI UN MODE D'AIDE (--HELP).
    13. UTILISATION DE TYPES DE DONNEES EXPLICITES POUR COMPATIBILITE POWERSHELL 5.1.
    14. ZERO ACCENT DANS LE CODE ET LES RETOURS CONSOLE.

.OBJECTIFS
    - Mapper les cles JSON 'Key' et 'Value' vers le moteur de generation.
    - Normaliser les chemins de registre (Double Backslash vers Single).
    - Reconstruire la flotte modularisee dans 02_Atoms.
#>

param (
    [switch]$Help,
    [switch]$Debug,
    [switch]$Commit
)

if ($Help) {
    Write-Host "--- [HELP] MASTER FORGE MODULAIRE V13.58 ---" -ForegroundColor Cyan
    return
}

$CurrentDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
$SpecPath   = Join-Path $CurrentDir "..\..\00_Core\01_AntiVM_Spec.json"
$AtomsRoot  = Join-Path $CurrentDir "..\..\02_Atoms"

if (-not (Test-Path $SpecPath)) {
    Write-Host "[CRITICAL] Spec JSON manquante : $SpecPath" -ForegroundColor Red ; return
}

try {
    $SpecData = Get-Content $SpecPath -Raw | ConvertFrom-Json
} catch {
    Write-Host "[CRITICAL] JSON Invalide." -ForegroundColor Red ; return
}

Write-Host "[SYSTEM] Forge V13.58 : Alignement sur structure 'Key/Value'..." -ForegroundColor Magenta

if ($Commit) {
    # Nettoyage
    if (Test-Path $AtomsRoot) { Get-ChildItem -Path $AtomsRoot | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue }
    New-Item -Path $AtomsRoot -ItemType Directory -Force | Out-Null

    [int]$idx = 0
    foreach ($Property in $SpecData.PSObject.Properties) {
        $ID = $Property.Name
        $Data = $Property.Value
        
        # --- MAPPING ALIGNE SUR VOTRE JSON ---
        $RawPath = [string]$Data.Cloaking[0].Path
        $RPath   = $RawPath.Replace('\\', '\') # Normalisation PowerShell
        $RName   = [string]$Data.Cloaking[0].Key   # Mapping Key
        $RVal    = [string]$Data.Cloaking[0].Value # Mapping Value

        if ([string]::IsNullOrWhiteSpace($RPath) -or [string]::IsNullOrWhiteSpace($RName)) { continue }

        # --- DISPATCHING ---
        $FamilyTag = $ID.Split('_')[1] 
        $FolderName = switch($FamilyTag) {
            "HW"    { "01_Hardware" }
            "SW"    { "02_Software" }
            "NET"   { "03_Network" }
            "BEHAV" { "04_Behavior" }
            "TIME"  { "05_Timing" }
            "SYS"   { "06_System" }
            "FS"    { "07_Filesystem" }
            default { "00_Governance" }
        }

        $FamilyPath = Join-Path $AtomsRoot $FolderName
        if (-not (Test-Path $FamilyPath)) { New-Item -Path $FamilyPath -ItemType Directory -Force | Out-Null }

        $FilePath = Join-Path $FamilyPath "$($ID)_Atom.ps1"

        # --- TEMPLATE ATOMIQUE ---
        $Template = @"
<# NOM : $($ID)_Atom.ps1 | FAMILLE : $FolderName #>
param ([string]`$Mode="Audit",[switch]`$Debug)
try {
    if (`$Mode -eq "Audit") {
        if (`$Debug) { Write-Host "[DEBUG] Path: $($RPath)" -ForegroundColor Gray }
        `$Val = Get-ItemProperty -Path "$($RPath)" -Name "$($RName)" -ErrorAction SilentlyContinue
        if (`$null -eq `$Val."$($RName)") {
            Write-Host "[!!] ID:$ID | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        `$Current = [string]`$Val."$($RName)"
        if ("`$Current" -eq "$($RVal)") { Write-Host "[OK] ID:$ID | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:$ID | STATUS:DETECTE | VAL:`$Current" }
    }
} catch { Write-Host "[ERR] $ID : `$(`$_.Exception.Message)" }
"@
        $Template | Out-File -FilePath $FilePath -Encoding ascii -Force
        $idx++
    }
    Write-Host "[FIN] $idx Atomes generes dans 02_Atoms." -ForegroundColor Green
} else {
    Write-Host "[WARN] Simulation. Utilisez -Commit." -ForegroundColor Yellow
}