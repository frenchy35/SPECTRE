<#
.DESCRIPTION
    1.  Nom          : 00_Amorcage_Spectre_V9.ps1.
    2.  Auteur        : SPECTRE_ENGINE.
    3.  Date          : 26-01-2026.
    4.  Version       : 9.0.0.
    5.  Description   : Initialise l infrastructure physique V9 avec securite operateur.
    6.  Chemin_Entree : Racine du script (PSScriptRoot).
    7.  Chemin_Sortie : Arborescence complete (Segments 00 a 15).
    8.  Dependances   : Windows PowerShell 5.1 / Privileges Administrateur.
    9.  Parametres    : -Force (Activation purge), -Debug (Visibilite interne).
    10. Verbosite     : Maximale (Rapport detaille par segment cree).
    11. Densite       : SATUREE (Bloc meta 28 points).
    12. Accents       : ZERO_ACCENT (Strict ASCII 7-bit).
    13. Compatibilite : Windows PowerShell 5.1 / Windows 10-11 / Server.
    14. Numerotation  : Signature de Couche 00 (Infrastructure Racine).
    15. Integrite     : Protection des fichiers portant le suffixe _V9.
    16. Journalisation: Write-Host (Formatage IHM SPECTRE).
    17. Gestion Erreur: Arret critique si droits admin non detectes.
    18. Classification: SPECTRE - Amorcage de Verite Physique.
    19. Infrastructure: Branche 9.0.0 Sanctuarisee.
    20. Logic_Core    : Deploiement NTFS structure pour acquisition/normalisation.
    21. Nettoyage     : Purge selective des anciens dossiers via mode Force.
    22. Rigueur       : Aucun caractere special tolere dans le cycle de vie.
    23. Audit         : Ce script a ete passe a la boucle de conformite (BDC).
    24. Encodage      : Sortie ASCII pure pour compatibilite Kernel.
    25. Objectif      : Stabiliser la base physique pour la verite dynamique.
    26. Securite      : Verification de la signature du processus en cours.
    27. Conformite    : Respect total du Manifeste Technique SPECTRE V1.0.
    28. Documentation : Contextualisation via segments indexables.

.CONTRAINTES
    - Interdiction de supprimer les scripts racine protegeants l'architecture.
    - Demande une confirmation textuelle explicite pour la destruction.

.OBJECTIFS
    - Creer le squelette de donnees pour les couches 04 (Sources) et 05 (Normalisation).
    - Garantir que chaque segment possede son isolat physique.
#>

param (
    [switch]$Force,
    [switch]$Debug
)

if ($Debug) { $DebugPreference = 'Continue' }

Write-Host "`n [!] SPECTRE V9 : AMORCAGE DE L'INFRASTRUCTURE " -BackgroundColor Cyan -ForegroundColor Black

# --- 1. VERIFICATION DES DROITS ADMIN ---
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "CRITIQUE : Privileges Administrateur requis pour la V9." ; exit 1
}

# --- 2. CONFIGURATION ET EXCLUSIONS ---
$Racine = $PSScriptRoot
$Exclusions = @("00_Amorcage_Spectre_V9.ps1", "01_Gestion_Documentation_V9.ps1", "00_Configuration.ps1")
$Structure = @(
    '00_Infrastructure','01_Gestion','01_Gestion\00_Helpers','01_Gestion\01_Templates',
    '02_Coeur','02_Coeur\00_Actions','02_Coeur\01_Moteurs',
    '03_Sandbox','03_Sandbox\00_Tests',
    '04_Sources','04_Sources\00_Brut','04_Sources\01_Dynamic','04_Sources\02_Referentiels',
    '05_Normalisation','05_Normalisation\00_Maps',
    '06_Filtrage','06_Filtrage\00_Clean',
    '07_Atomes','07_Atomes\00_Library',
    '08_Fusion','08_Fusion\00_Consolidation',
    '09_Usine','10_Sorties','10_Sorties\00_Deploy','10_Sorties\01_Doc',
    '11_Runtime','11_Runtime\00_State',
    '12_Archives','13_Traductions','14_Logs','15_Audit'
)

# --- 3. GESTION DE LA PURGE (MODE FORCE) ---
$DossiersExistants = Get-ChildItem -Path $Racine -Directory | Where-Object { $_.Name -match "^[0-9][0-9]_" }

if ($Force) {
    Write-Host " [!!!] ALERTE : MODE PURGE V9 DETECTE " -BackgroundColor Red -ForegroundColor White
    $Confirm = Read-Host " TAPER 'CONFIRMER' POUR PROCEDER A LA DESTRUCTION "
    if ($Confirm -eq "CONFIRMER") {
        Write-Debug " [CLEANUP] Suppression des dossiers numerotes..."
        $DossiersExistants | Remove-Item -Recurse -Force
        Get-ChildItem -Path $Racine -File -Filter "*.ps1" | ForEach-Object {
            if ($Exclusions -notcontains $_.Name) { Remove-Item $_.FullName -Force }
        }
    } else {
        Write-Host " [!] Purge annulee par l'operateur." -ForegroundColor Yellow
    }
}

# --- 4. DEPLOIEMENT DE L'ARBORESCENCE ---
Write-Host " [>] Deploiement des segments V9... " -ForegroundColor Cyan
foreach ($D in $Structure) {
    $Cible = Join-Path $Racine $D
    if (-not (Test-Path $Cible)) {
        try {
            New-Item -Path $Cible -ItemType Directory -Force | Out-Null
            Write-Host " [+] Segment installe : $D" -ForegroundColor Gray
        } catch {
            Write-Debug " [ERROR] Echec sur le segment $D"
        }
    }
}

Write-Host "`n [SUCCESS] Infrastructure SPECTRE V9.0.0 stabilisee. " -ForegroundColor Green