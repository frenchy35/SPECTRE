<#
.DESCRIPTION
    NOM : 06_Action_Report.ps1 | TYPE : Actionneur
    ARCHITECTURE : SPECTRE V7.1.2 | [FONCTION] : Export Rapport d'Audit.
    
    LISTE DES OBLIGATIONS ET DIRECTIVES :
    1. VERBOSITE TOTALE
    2. ZERO INVENTION
    3. ZERO AMPUTATION
    4. AUDIT GRANULAIRE
    5. REVERSIBILITE
    6. VERIF. FONCTIONNELLE
    7. DOC EMBARQUEE
    8. CONFRONTATION
    9. SEPARATION CORE/ATOME
    10. PAS DE PARESSE
    11. ISOLATION SCOPE
    12. QUADRI-FONCTIONNALITE
    13. LISTE VERTICALE
    14. RESOLUTION SEMANTIQUE
#>
param(
    [Parameter(Mandatory=$false)] [String]$Scope = "*"
)

# --- 1. ANCRAGE ET SORTIE ---
$CurrentDir  = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
$ProjectRoot = Split-Path $CurrentDir -Parent
$AtomsDir    = Join-Path $ProjectRoot "02_Atoms\03_D_Defense"
$ReportDir   = Join-Path $ProjectRoot "06_Out\Reports"

if (-not (Test-Path $ReportDir)) { New-Item $ReportDir -ItemType Directory -Force | Out-Null }

$Timestamp   = Get-Date -Format "yyyyMMdd_HHmm"
$ReportFile  = Join-Path $ReportDir "Audit_Report_$Timestamp.txt"

# --- 2. EXECUTION ET CAPTURE ---
Write-Host "--- [SPECTRE] GENERATION RAPPORT D'AUDIT ---" -ForegroundColor Cyan
Write-Host "[>] Sortie : $ReportFile" -ForegroundColor Gray

$Atoms = Get-ChildItem $AtomsDir -Filter "$Scope*.ps1" | Sort-Object Name

$ReportContent = @("--- SPECTRE AUDIT REPORT | $Timestamp ---`n")

foreach ($Atom in $Atoms) {
    Write-Host "[V] Scan : $($Atom.Name)" -ForegroundColor Magenta
    $Output = & $Atom.FullName -Mode Audit | Out-String
    $ReportContent += "[ATOME] : $($Atom.Name)"
    $ReportContent += $Output
    $ReportContent += ("-" * 30)
}

$ReportContent | Out-File $ReportFile -Encoding ascii -Force
Write-Host "`n--- [RAPPORT TERMINE] ---" -ForegroundColor Cyan