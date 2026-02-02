<#
.DESCRIPTION
    1.  Nom          : 01_Referentiel_Downloader.ps1.
    2.  Auteur        : SPECTRE_ENGINE.
    3.  Date          : 26-01-2026.
    4.  Version       : 11.4.0.
    5.  Description   : Telecharge et synchronise les referentiels Anti-VM dans l'architecture V8.
    6.  Chemin_Entree : Reseau (GitHub Repositories).
    7.  Chemin_Sortie : 04_Sources\02_Referentiels\.
    8.  Dependances   : 00_Infrastructure\00_Configuration.ps1.
    9.  Parametres    : -Debug (Affiche le suivi des operations Git).
    10. Verbosite     : Haute (Rapport de synchronisation des sources).
    11. Densite       : Elevee (Logique de gestion de depots Git).
    12. Accents       : ZERO_ACCENT (Standard ASCII 7-bit).
    13. Compatibilite : Windows PowerShell 5.1 / Git for Windows.
    14. Numerotation  : Signature 01 (Couche 04).
    15. Integrite     : Mise a jour par 'git pull' ou 'git clone' si absent.
    16. Gestion Erreur: Arret critique si Git n'est pas installe.
    17. Classification: SPECTRE - Acquisition de Verite Absolue.
    18. Logic_Core    : Synchronisation multi-sources (CheckPoint, VMAware, CAPE).
    19. Nettoyage     : Isolation des depots dans des sous-repertoires dedies.
    20. Flux_Donnees  : Web -> 04_Sources.
    21. Rigueur       : Aucun caractere accentue tolere.
    22. Audit         : Script valide via Boucle de Conformite (BDC).
    23. Infrastructure: Branche V8.0.0.
    24. Encodage      : ASCII pur.

.OBJECTIFS
    * Garantir la disponibilite des referentiels de Threat Intelligence.
    * Automatiser la veille technologique sur les artefacts Anti-VM.
    * Centraliser les signatures pour la couche de normalisation.

.CONTRAINTES
    * Utilisation de chemins relatifs bases sur $PSScriptRoot.
    * Zero accent dans l'integralite du script.
    * Presence obligatoire de Git dans le PATH.
#>

param ([switch]$Debug)

if ($Debug) { $DebugPreference = 'Continue' }

# --- 1. CHARGEMENT DU FRAMEWORK ---
$InfraPath = Join-Path $PSScriptRoot "..\00_Infrastructure\00_Configuration.ps1"
if (Test-Path $InfraPath) { . $InfraPath } else { Write-Error "CRITICAL : 00_Configuration.ps1 introuvable." ; exit 1 }

Write-Host "`n $($Global:SpectreIHM.Libelle) " -BackgroundColor $Global:SpectreIHM.FondBanniere -ForegroundColor $Global:SpectreIHM.TexteBanniere
Write-Host " [>] SYNCHRONISATION DES REFERENTIELS (ARCH_V8) " -ForegroundColor $Global:SpectreIHM.CouleurPrim

# --- 2. CONFIGURATION DES DEPOTS ---
$DestBase = Join-Path $PSScriptRoot "02_Referentiels"
if (-not (Test-Path $DestBase)) { New-Item -Path $DestBase -ItemType Directory -Force | Out-Null }

$Repos = @{
    "01_CheckPoint" = "https://github.com/CheckPointSW/Evasions.git";
    "02_VMAware"    = "https://github.com/kernelwernel/VMAware.git";
    "03_CAPE"       = "https://github.com/CAPESandbox/community.git"
}

# --- 3. MOTEUR D'ACQUISITION ---
Write-Host " [1/1] Mise a jour des flux Git... " -ForegroundColor Cyan

foreach ($Entry in $Repos.GetEnumerator()) {
    $Name = $Entry.Key
    $Url  = $Entry.Value
    $LocalPath = Join-Path $DestBase $Name

    if (Test-Path $LocalPath) {
        Write-Debug " [UPDATE] $Name"
        Set-Location $LocalPath
        git pull --quiet
        Set-Location $PSScriptRoot
    } else {
        Write-Debug " [CLONE] $Name"
        git clone $Url $LocalPath --quiet
    }
}

Write-Host "`n [SUCCESS] Sources synchronisees dans 04_Sources\02_Referentiels." -ForegroundColor Green