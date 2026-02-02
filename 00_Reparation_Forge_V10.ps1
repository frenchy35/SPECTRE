<#
.DESCRIPTION
1. Nom : 00_Reparation_Forge_V10.ps1
2. Auteur : SPECTRE_ENGINE
3. Date : 02-02-2026
4. Version : 10.1.7
5. Description : Force la re-indexation totale en ignorant les blocages .gitignore et en nettoyant le cache.
6. Entrees : G:\Mon Drive\PROJETS\EN_COURS\SPECTRE
7. Sorties : Index Git mis a jour et prêt pour le push.
8. Dependances : Git for Windows, 00_Configuration.ps1
9. Parametres : --Debug
10. Verbosite : Maximale
11. Densite : Haute
12. Accents : ZERO_ACCENT (Strict ASCII 7-bit)
13. Compatibilite : Windows PowerShell 5.1
14. Numerotation : Standard SPECTRE
15. Source_In : G:\Mon Drive\PROJETS\EN_COURS\SPECTRE
16. Destination_Out : GitHub/frenchy35/SPECTRE
17. Objectifs : Peupler le depot distant avec TOUTES les versions.
18. Contraintes : Interdiction de caractere non-ASCII.
19. Audit_BDC : PASSE
20. Logic_Core : Index Reset & Force Add
21. Validation : Check post-execution via git status
#>

# Chargement du Framework SPECTRE
$SPOT_Path = "G:\Mon Drive\PROJETS\EN_COURS\SPECTRE\00_Infrastructure\00_Configuration.ps1"
if (Test-Path $SPOT_Path) { . $SPOT_Path }

Write-Host " [!] SPECTRE | AMORCAGE DE LA REPARATION FORCEE" -ForegroundColor Cyan

# 1. Nettoyage de l index (Git oublie tout mais garde les fichiers sur disque)
Write-Host " [PROCESS] Nettoyage du cache de l index..."
git rm -r --cached . --quiet

# 2. Suppression temporaire du .gitignore pour forcer l ingestion
if (Test-Path ".gitignore") {
    Write-Host " [CHECK] Neutralisation temporaire du .gitignore..."
    Rename-Item ".gitignore" ".gitignore.bak"
}

# 3. Ajout Force de TOUTE la structure
Write-Host " [PROCESS] Ingestion massive de toutes les branches (V6.5 a V9.0)..."
git add . -v

# 4. Restauration du .gitignore
if (Test-Path ".gitignore.bak") {
    Rename-Item ".gitignore.bak" ".gitignore"
}

# 5. Validation finale
Write-Host " [OK] Indexation terminee. Verifiez le statut ci-dessous :"
git status

Write-Host "`n [>] Executez maintenant : git commit -m 'SPECTRE : Restauration Totale' et git push origin main" -ForegroundColor Yellow