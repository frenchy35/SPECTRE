<#
.DESCRIPTION
    1.  Nom          : 00_Configuration.ps1.
    2.  Auteur        : SPECTRE_ENGINE.
    3.  Date          : 27-01-2026.
    4.  Version       : 9.0.0.
    5.  Description   : Pivot central d injection des variables Globales SPECTRE.
    6.  Chemin_Entree : N/A (Initialisation).
    7.  Chemin_Sortie : Scope Global (In-Memory).
    8.  Dependances   : Aucune (Script Racine).
    9.  Parametres    : Aucune.
    10. Verbosite     : Basse (Confirmation de chargement).
    11. Densite       : MOYENNE (Variables de Mapping).
    12. Accents       : ZERO_ACCENT (Strict ASCII 7-bit).
    13. Compatibilite : Windows PowerShell 5.1.
    14. Numerotation  : Signature 00 (Infrastructure).
    15. Integrite     : Resolution dynamique de la racine via PSScriptRoot.
    16. Journalisation: Write-Host (Standard SPECTRE).
    17. Gestion Erreur: Arret si la structure de dossier est invalide.
    18. Classification: SPECTRE - Core Infrastructure.
    19. Infrastructure: Branche 9.0.0 (Sanctuaire).
    20. Logic_Core    : Global Scope Injection.
    21. Nettoyage     : Normalisation ASCII 7-bit systematique.
    22. Rigueur       : Aucun caractere accentue tolere.
    23. Audit         : Ce script a ete passe a la boucle de conformite (BDC).
    24. Encodage      : ASCII Pur.
    25. Objectif      : Eradication des donnees en dur dans les scripts enfants.
    26. Securite      : Isolation des chemins absolus.
    27. Conformite    : Standard industriel SPECTRE V2.0.
    28. Trace         : Heritage systematique.
#>

# --- 1. RESOLUTION DE LA RACINE DU PROJET ---
# On remonte d un cran pour sortir de 00_Infrastructure
$Root = (Get-Item $PSScriptRoot).Parent.FullName

# --- 2. INJECTION DES CHEMINS (GLOBAL SCOPE) ---
$Global:SpectrePaths = @{
    Root            = $Root
    # Sources Brutes
    CheckPoint      = Join-Path $Root "04_Sources\02_Referentiels\01_CheckPoint"
    Cape            = Join-Path $Root "04_Sources\02_Referentiels\02_CAPE"
    VMWare          = Join-Path $Root "04_Sources\02_Referentiels\03_VMWare"
    # Destination Couche 05 (Normalisation)
    NormalizedDir   = Join-Path $Root "05_Normalisation"
    AtlasCP         = Join-Path $Root "05_Normalisation\01_Atlas_CheckPoint.txt"
    # Fichiers de Debug et Discovery
    DebugPathsCP    = Join-Path $Root "05_Normalisation\99_DEBUG_Paths_CheckPoint.txt"
}

# --- 3. CONFIGURATION LOGIQUE ET FILTRES ---
$Global:SpectreConfig = @{
    # Liste des chemins suspects (Alerte lors de l arbitrage interactif)
    Exclusions = @(
        'C:\Users\', 
        'C:\Windows\', 
        'C:\Temp', 
        'C:\$', 
        'HKEY_LOCAL_MACHINE\Software\Classes'
    )
    # Extensions techniques autorisees
    AllowedExtensions = @('.exe', '.sys', '.dll', '.ps1', '.pdb')
}

# --- 4. IDENTITE VISUELLE ET IHM ---
$Global:SpectreIHM = @{
    Libelle       = " SPECTRE | V9.0.0 | POINT DE VERITE UNIQUE "
    FondBanniere  = "Black"
    TexteBanniere = "White"
    CouleurPrim   = "Cyan"
    CouleurSec    = "Yellow"
}

# --- 5. VALIDATION DU CHARGEMENT ---
if (Test-Path $Global:SpectrePaths.Root) {
    Write-Host "`n [OK] SPOT DYNAMIQUE CHARGE (V9.0.0)." -ForegroundColor Green
    Write-Host " [INFRA] Branche : 9.0.0 (Mapping Global Actif) " -ForegroundColor Gray
} else {
    Write-Error "CRITIQUE : La racine SPECTRE est inaccessible."
}