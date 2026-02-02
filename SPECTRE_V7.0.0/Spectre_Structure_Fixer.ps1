<#
.DESCRIPTION
    NOM : Spectre_Structure_Fixer.ps1
    VERSION : 1.0.0
    Assure que l architecture locale est identique sur GitHub en creant des fichiers .gitkeep.
    [CONTRAINTES] : Zero accent. Encodage ASCII.
#>

$ProjectRoot = "C:\Users\LGE\Mon Drive\PROJETS\EN_COURS\SPECTRE"

# --- LISTE DES DOSSIERS A "FORCER" SUR GITHUB ---
# On inclut meme les dossiers de sortie (vides) pour preserver l architecture ISO-13
$TargetFolders = Get-ChildItem -Path $ProjectRoot -Recurse -Directory

Write-Host "[STRUCTURE] Analyse de l'arborescence..." -ForegroundColor Cyan

foreach ($Dir in $TargetFolders) {
    # Verifier si le dossier est vide ou ne contient pas de fichiers suivis
    $Content = Get-ChildItem -Path $Dir.FullName -File
    if ($null -eq $Content) {
        $KeepFile = Join-Path $Dir.FullName ".gitkeep"
        if (-not (Test-Path $KeepFile)) {
            New-Item -Path $KeepFile -ItemType File -Force | Out-Null
            Write-Host "[KEEP] Cree dans : $($Dir.FullName)" -ForegroundColor Gray
        }
    }
}

Write-Host "[SUCCESS] Tous les dossiers sont maintenant suivis par Git." -ForegroundColor Green