<#
.DESCRIPTION
    1.  Nom          : 00_Configuration.ps1
    2.  Auteur        : SPECTRE_ENGINE
    3.  Date          : 22-01-2026
    4.  Version       : 8.4.0
    5.  Description   : Point de Verite Unique (SPOT). Centralise l identite visuelle, les constantes systeme et l Atlas des flux.
    12. Accents       : ZERO_ACCENT.
    14. Numerotation  : 00_.

.CONTRAINTES
    - Doit definir des couleurs compatibles avec la console Windows native.
    - Toute nouvelle couche doit etre declaree dans $Global:SpectreAtlas.
#>

# --- IDENTITE VISUELLE ---
$Global:SpectreIHM = @{
    CouleurPrim   = 'Cyan'
    CouleurSec    = 'Gray'
    CouleurAlerte = 'Yellow'
    CouleurErreur = 'Red'
    FondBanniere  = 'Cyan'
    TexteBanniere = 'Black'
    Prefixe       = '[!]'
    Libelle       = ' SPECTRE | ATLAS SECURITY | V8.4.0 '
}

# --- CARTOGRAPHIE TECHNIQUE (FLUX CTI) ---
$Global:SpectreAtlas = @{
    '.'                 = @{ Nom='RACINE'; Desc='Orchestration Globale'; InQui='Operateur'; InOu='CLI'; OutQui='Couches 00-09'; OutOu='Filesystem'; Quoi='Commandes' }
    '00_Infrastructure' = @{ Nom='INFRA'; Desc='Configuration et SPOT'; InQui='Admin'; InOu='Config.ps1'; OutQui='Memoire'; OutOu='Global:Variables'; Quoi='Parametres' }
    '01_Coeur'          = @{ Nom='COEUR'; Desc='Moteur de decision TTP'; InQui='Fusion'; InOu='05_Fusion'; OutQui='Moteurs'; OutOu='01_Moteurs'; Quoi='Intelligence' }
    '02_Sources'        = @{ Nom='SOURCES'; Desc='Acquisition CTI (MITRE/ART)'; InQui='Web/API'; InOu='HTTPS'; OutQui='Filtrage'; OutOu='02_Brut'; Quoi='JSON' }
    '03_Filtrage'       = @{ Nom='FILTRAGE'; Desc='Normalisation et Nettoyage'; InQui='Brut'; InOu='02_Brut'; OutQui='Atomes'; OutOu='04_Atomes'; Quoi='JSON Normalise' }
    '04_Atomes'         = @{ Nom='ATOMES'; Desc='Bibliotheque d unites TTP'; InQui='Filtrage'; InOu='03_Filtrage'; OutQui='Fusion'; OutOu='05_Fusion'; Quoi='Atomes' }
    '05_Fusion'         = @{ Nom='FUSION'; Desc='Consolidation de l Atlas'; InQui='Atomes'; InOu='04_Atomes'; OutQui='Coeur'; OutOu='Atlas.json'; Quoi='Referentiel' }
}

Write-Host " [OK] SPOT Charge : Identite et Atlas synchronises." -ForegroundColor $Global:SpectreIHM.CouleurSec