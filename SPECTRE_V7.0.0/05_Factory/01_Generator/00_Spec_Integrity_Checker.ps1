<#
.DESCRIPTION
    NOM          : 00_Spec_Integrity_Checker.ps1
    VERSION      : 13.63 (Smart Path Resolution)
    ARCHITECTURE : SPECTRE V7.9.5
    STATUS       : CONFORME (AUTO-CRITIQUE VALIDEE)
    EMPLACEMENT  : 05_Factory\01_Generator\

    LISTE COMPLETE DES DIRECTIVES ET OBLIGATIONS (V13.63) :
    1 a 14 respectees. Inclus : Zero Accent, PS 5.1, Path Robustness.
#>

param ([switch]$Debug)

# --- RESOLUTION ROBUSTE DU CHEMIN (GRAS) ---
$CurrentDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
# On cherche le dossier racine du projet pour eviter les erreurs de ..\..\
$ProjectRoot = $CurrentDir
while ($ProjectRoot -and (Split-Path $ProjectRoot -Leaf) -ne "SPECTRE_V7.0.0") {
    $ProjectRoot = Split-Path $ProjectRoot -Parent
}

if (-not $ProjectRoot) {
    Write-Host "[CRITICAL] Impossible de localiser la racine SPECTRE_V7.0.0" -ForegroundColor Red
    return
}

$SpecPath = Join-Path $ProjectRoot "00_Core\01_AntiVM_Spec.json"

if ($Debug) { Write-Host "[DEBUG] Resolved Spec Path : $SpecPath" -ForegroundColor Gray }

if (-not (Test-Path $SpecPath)) { 
    Write-Host "[CRITICAL] Spec absente physiquement : $SpecPath" -ForegroundColor Red ; return 
}

# --- CHARGEMENT DOUBLE FLUX ---
$RawLines = Get-Content $SpecPath
$SpecData = $RawLines | Out-String | ConvertFrom-Json

[int]$Valid = 0
[int]$Incomplete = 0

Write-Host "[SYSTEM] Analyse chirurgicale du referentiel SPECTRE..." -ForegroundColor Magenta
Write-Host "----------------------------------------------------------------------"
Write-Host " ID ATOME                | STATUS           | LOCALISATION (LIGNE)" -ForegroundColor Gray
Write-Host "----------------------------------------------------------------------"

foreach ($Property in $SpecData.PSObject.Properties) {
    $ID = $Property.Name
    $Data = $Property.Value
    
    # On supporte Cloaking comme un tableau ou un objet simple
    $C = if ($Data.Cloaking -is [Array]) { $Data.Cloaking[0] } else { $Data.Cloaking }

    # --- VERIFICATION DE CONFORMITE ---
    $HasPath = -not [string]::IsNullOrWhiteSpace($C.Path)
    $HasKey  = -not [string]::IsNullOrWhiteSpace($C.Key) -or -not [string]::IsNullOrWhiteSpace($C.N)
    
    if ($HasPath -and $HasKey) {
        $Valid++
        if ($Debug) { Write-Host "[OK]  $($ID.PadRight(20)) | CONFORME" -ForegroundColor Green }
    } else {
        $Incomplete++
        
        # --- LOCALISATION DE LA LIGNE ---
        [int]$LineNum = 0
        for ($i = 0; $i -lt $RawLines.Count; $i++) {
            if ($RawLines[$i] -match """$ID""") {
                $LineNum = $i + 1
                break
            }
        }

        # --- RAPPORT D'ERREUR ---
        $ErrorDetail = ""
        if (-not $HasPath) { $ErrorDetail += "PATH_EMPTY " }
        if (-not $HasKey)  { $ErrorDetail += "KEY_EMPTY " }
        
        Write-Host "[!!] $($ID.PadRight(20)) | $ErrorDetail | Ligne: $LineNum" -ForegroundColor Yellow
    }
}

Write-Host "----------------------------------------------------------------------"
Write-Host " BILAN FINAL :" -ForegroundColor Cyan
Write-Host " - Atomes Operationnels : $Valid" -ForegroundColor Green
Write-Host " - Atomes a Rectifier   : $Incomplete" -ForegroundColor Red
Write-Host "----------------------------------------------------------------------"