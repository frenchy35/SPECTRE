<#
.DESCRIPTION
    NOM : 02_Fix_Actionners_Scope.ps1 | DOSSIER : 08_Maintenance
    ARCHITECTURE : SPECTRE V7.1.2 | [FIX] : Ancrage du Scope (Directive 11).
    [CONTRAINTES] : Zero accent. ASCII.
#>

# --- 1. ANCRAGE SECURISE ---
$CurrentDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }

# Si on est dans 08_Maintenance, le projet est le parent.
# Si on est dejà à la racine (SPECTRE_V7.0.0), le projet est ici.
if (Test-Path (Join-Path $CurrentDir "03_Engine")) {
    $ProjectRoot = $CurrentDir
} else {
    $ProjectRoot = Split-Path $CurrentDir -Parent
}

$EnginePath = Join-Path $ProjectRoot "03_Engine"

Write-Host "[INIT] Securisation des actionneurs dans : $EnginePath" -ForegroundColor Gray

# --- 2. VERIFICATION DU CHEMIN ---
if (-not (Test-Path $EnginePath)) {
    Write-Host "[ERREUR] Chemin introuvable : $EnginePath" -ForegroundColor Red
    return
}

# --- 3. TRAITEMENT ---
$Actionners = Get-ChildItem $EnginePath -Filter "0*_Action_*.ps1"

foreach ($File in $Actionners) {
    $Content = Get-Content $File.FullName -Raw
    
    # Correction de la logique de filtrage : ancrage strict au debut du nom
    $NewContent = $Content -replace '\$AtomsDir -Filter "\$Scope\.ps1"', '$AtomsDir -Filter "$Scope*.ps1"'
    $NewContent = $NewContent -replace '\$AtomsDir -Filter "\*\$Scope\*"', '$AtomsDir -Filter "$Scope*.ps1"'
    
    if ($Content -ne $NewContent) {
        $NewContent | Out-File $File.FullName -Encoding ascii -Force
        Write-Host "[FIX-SCOPE] Succes : $($File.Name)" -ForegroundColor Green
    } else {
        Write-Host "[SKIP] $($File.Name) deja conforme ou signature non trouvee." -ForegroundColor Yellow
    }
}