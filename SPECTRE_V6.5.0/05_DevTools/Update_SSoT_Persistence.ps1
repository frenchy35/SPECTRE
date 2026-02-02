<#
.DESCRIPTION
    SPECTRE SSoT MAINTENANCE
    Convertit RebootRequired en String et injecte "Never" sur les points de verrouillage.
    NB LIGNES : 45
#>

$ProjectRoot = Split-Path $PSScriptRoot -Parent
$ProfilesDir = Join-Path $ProjectRoot "01_Profiles"
# Liste des IDs cibles pour la contrainte "Never" (Verrouillage de segment)
$LockPoints = @("025", "125", "230", "330", "430", "530")

if (-not (Test-Path $ProfilesDir)) { Write-Error "ProfilesDir introuvable."; return }

$JsonFiles = Get-ChildItem -Path $ProfilesDir -Filter "*.json"

foreach ($File in $JsonFiles) {
    Write-Host "[PROCESS] $($File.Name)..." -ForegroundColor Cyan
    $Data = Get-Content -Raw $File.FullName | ConvertFrom-Json
    $Modified = $false

    foreach ($Point in $Data.KnowledgePoints) {
        # 1. Conversion systematique en String
        $CurrentVal = [string]$Point.RebootRequired
        
        # 2. Injection de la contrainte "Never"
        if ($LockPoints -contains [string]$Point.ID) {
            if ($Point.RebootRequired -ne "Never") {
                $Point.RebootRequired = "Never"
                $Modified = $true
                Write-Host "  -> Point [$($Point.ID)] : Set to NEVER (Lock Priority)" -ForegroundColor Yellow
            }
        } else {
            # Normalisation des booleens existants en String True/False
            if ($Point.RebootRequired -is [bool]) {
                $Point.RebootRequired = $CurrentVal
                $Modified = $true
            }
        }
    }

    if ($Modified) {
        # Export avec profondeur suffisante pour ne pas perdre la structure KnowledgePoints
        $Data | ConvertTo-Json -Depth 10 | Out-File -FilePath $File.FullName -Encoding utf8 -Force
        Write-Host "  [OK] Fichier mis a jour." -ForegroundColor Green
    }
}

Write-Host "`n[TERMINE] La base SSoT est desormais alignee sur la contrainte de persistance." -ForegroundColor Cyan