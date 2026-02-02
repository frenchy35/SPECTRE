<#
.DESCRIPTION
    NOM : 05_Action_Debug.ps1 | TYPE : Actionneur
    ARCHITECTURE : SPECTRE V7.1.2 | [CONTRAINTES] : Zero accent. ASCII.
    
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

# --- 1. ANCRAGE ---
$CurrentDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
$ProjectRoot = Split-Path $CurrentDir -Parent
$AtomsDir = Join-Path $ProjectRoot "02_Atoms\03_D_Defense"

# --- 2. EXECUTION ---
Write-Host "--- [SPECTRE] ACTION : DEBUG ---" -ForegroundColor White
$Atoms = Get-ChildItem $AtomsDir -Filter "$Scope*.ps1" | Sort-Object Name

foreach ($Atom in $Atoms) {
    Write-Host "`n[D] Debug : $($Atom.Name)" -ForegroundColor Gray
    & $Atom.FullName -Mode Debug
}
Write-Host "`n--- [FIN D'ACTION] ---" -ForegroundColor White
