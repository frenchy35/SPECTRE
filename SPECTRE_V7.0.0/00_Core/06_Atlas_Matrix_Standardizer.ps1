<#
.DESCRIPTION
    NOM          : 06_Atlas_Matrix_Standardizer.ps1
    VERSION      : 13.68 (Rollback Enabled)
    ARCHITECTURE : SPECTRE V7.9.9
    STATUS       : CONFORME (AUTO-CRITIQUE VALIDEE)
    EMPLACEMENT  : 00_Core\

    LISTE COMPLETE DES DIRECTIVES ET OBLIGATIONS (V13.68) :
    1 a 14 respectees. Inclus : Zero Accent, PS 5.1, Rollback Logic, Smart Path.
#>

param (
    [switch]$Help,
    [switch]$Debug,
    [switch]$Commit,
    [switch]$Rollback
)

if ($Help) {
    Write-Host "--- [HELP] ATLAS MATRIX STANDARDIZER V13.68 ---" -ForegroundColor Cyan
    Write-Host "Usage : -Commit (Applique) | -Rollback (Restaure la derniere version)"
    return
}

# --- RESOLUTION RACINE ---
$CurrentDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
$SpecPath   = Join-Path $CurrentDir "01_AntiVM_Spec.json"
$BackupPath = Join-Path $CurrentDir "01_AntiVM_Spec.json.bak"

# --- LOGIQUE DE ROLLBACK (OBLIGATION N°11) ---
if ($Rollback) {
    if (Test-Path $BackupPath) {
        Write-Host "[SYSTEM] Restauration du referentiel depuis le backup..." -ForegroundColor Yellow
        Copy-Item -Path $BackupPath -Destination $SpecPath -Force
        Write-Host "[SUCCESS] Rollback termine." -ForegroundColor Green
    } else {
        Write-Host "[ERR] Aucun backup disponible pour le rollback." -ForegroundColor Red
    }
    return
}

if (-not (Test-Path $SpecPath)) { Write-Host "[ERR] Spec absente." -ForegroundColor Red ; return }

# --- PREPARATION DU COMMIT ---
if ($Commit) {
    if ($Debug) { Write-Host "[DEBUG] Creation d'une Shadow-Copy avant modification..." -ForegroundColor Gray }
    Copy-Item -Path $SpecPath -Destination $BackupPath -Force
}

$SpecData = Get-Content $SpecPath -Raw | ConvertFrom-Json
$DefaultColumns = @{ "T" = "Registry"; "Path" = ""; "Key" = ""; "Value" = ""; "Mode" = "Cloak" }
[int]$Fixed = 0

Write-Host "[SYSTEM] Standardisation matricielle en cours..." -ForegroundColor Magenta

foreach ($Property in $SpecData.PSObject.Properties) {
    $ID = $Property.Name
    $Data = $Property.Value
    
    if ($null -eq $Data.Cloaking) { 
        $Data | Add-Member -MemberType NoteProperty -Name "Cloaking" -Value @((New-Object PSObject))
    }
    
    $C = $Data.Cloaking[0]

    # Injection des membres manquants (Normalisation Atlas)
    foreach ($Col in $DefaultColumns.Keys) {
        if ($null -eq $C.$Col) {
            $C | Add-Member -MemberType NoteProperty -Name $Col -Value $DefaultColumns[$Col] -Force
            $Fixed++
        }
    }
    
    # Migration Legacy N -> Key
    if ([string]::IsNullOrWhiteSpace($C.Key) -and (-not [string]::IsNullOrWhiteSpace($C.N))) {
        $C.Key = $C.N
    }
}

if ($Commit) {
    $SpecData | ConvertTo-Json -Depth 10 | Out-File -FilePath $SpecPath -Encoding ascii -Force
    Write-Host "[SUCCESS] Matrice normalisee. $Fixed colonnes traitees." -ForegroundColor Green
} else {
    Write-Host "[WARN] Mode simulation (Audit). Utilisez -Commit pour fixer ou -Rollback pour annuler." -ForegroundColor Yellow
}