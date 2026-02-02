<#
.DESCRIPTION
    NOM : Audit_Coverage.ps1 | VERSION : 1.0.0
    PRINCIPE DE FONCTIONNEMENT : Analyse le dossier 02_Atoms pour detecter les charges utiles actives.
    Il scanne le contenu des scripts pour identifier les fonctions Invoke-Action-X injectees.
    --- OBLIGATIONS ET CONTRAINTES SPECTRE ---
    1. VERBOSITE TOTALE 2. ZERO INVENTION 3. DATA-DRIVEN 4. SCRIPTS COMPLETS
    5. OUT-SPECTRE 6. CODES COULEURS 7. SECURITE DEFENSE 8. DOC-CONFORMITE
    9. STRICT TYPING 10. ASCII CLEAN 11. ISOLATION SCOPE 12. OBLIGATION CLEANUP
    13. AUDIT TRAILING 14. AUTO-BYPASS
#>

function Out-Spectre {
    param([string]$M, [string]$L="INFO")
    $local_T = Get-Date -Format "HH:mm:ss.fff"
    $local_C = switch($L) { "ERR"{"Red"} "WARN"{"Yellow"} "SUCCESS"{"Green"} "DEBUG"{"Cyan"} Default{"Gray"} }
    $local_N = $M.Normalize([System.Text.NormalizationForm]::FormD)
    $local_B = [System.Text.Encoding]::ASCII.GetBytes($local_N)
    $local_Clean = [System.Text.Encoding]::ASCII.GetString($local_B).Replace('?', '')
    Write-Host "[$local_T][$L][AUDIT_COVER] $local_Clean" -ForegroundColor $local_C
}

$ProjectRoot = "C:\Users\LGE\Mon Drive\PROJETS\EN_COURS\SPECTRE\SPECTRE_V7.0.0"
$AtomsFolder = Join-Path $ProjectRoot "02_Atoms"

Out-Spectre "Lancement de l'audit de couverture de l'arsenal..." "DEBUG"

if (-not (Test-Path $AtomsFolder)) {
    Out-Spectre "ERREUR : Dossier des atomes introuvable." "ERR"
    return
}

$local_Files = Get-ChildItem -Path $AtomsFolder -Filter "*.ps1"
$local_Total = $local_Files.Count
$local_ActiveAtoms = @()
$local_DocAtoms = @()

foreach ($local_File in $local_Files) {
    $local_Content = Get-Content $local_File.FullName -Raw
    
    # Detection des payloads actifs (fonctions de templates injectees)
    if ($local_Content -match "Invoke-Action-(Registry|File|Process|Service|Hardware|Timing)") {
        $local_ActiveAtoms += $local_File.Name
    } else {
        $local_DocAtoms += $local_File.Name
    }
}

# --- AFFICHAGE DU RAPPORT (OBLIGATION 1 & 6) ---
$local_Percent = [math]::Round(($local_ActiveAtoms.Count / $local_Total) * 100, 2)

Write-Host "`n" + ("=" * 60) -ForegroundColor Gray
Out-Spectre "RAPPORT DE COUVERTURE SPECTRE" "SUCCESS"
Write-Host ("=" * 60) -ForegroundColor Gray
Out-Spectre "TOTAL ATOMES ANALYSES : $local_Total" "DEBUG"
Out-Spectre "ATOMES OPERATIONNELS  : $($local_ActiveAtoms.Count)" "SUCCESS"
Out-Spectre "ATOMES DOCUMENTAIRES : $($local_DocAtoms.Count)" "WARN"
Out-Spectre "TAUX DE COMPLETUDE    : $local_Percent %" "DEBUG"
Write-Host ("=" * 60) -ForegroundColor Gray

if ($local_ActiveAtoms.Count -gt 0) {
    Out-Spectre "LISTE DES ATOMES PRETS AU COMBAT :" "SUCCESS"
    $local_ActiveAtoms | ForEach-Object { Write-Host "  [+] $_" -ForegroundColor Green }
}
Write-Host "`n"