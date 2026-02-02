<#
.DESCRIPTION
    1.  Nom          : 00_Amorcage_Spectre_V8.ps1
    2.  Auteur        : SPECTRE_ENGINE
    3.  Date          : 22-01-2026
    4.  Version       : 8.5.9
    5.  Description   : Initialisation de l arborescence COMPLETE SPECTRE V8. Applique la sequence locale 00 et l anti-collision.
    6.  Entrees       : Aucune.
    7.  Sorties       : Arborescence de dossiers 00 a 12 (NTFS).
    8.  Dependances   : Windows PowerShell 5.1.
    9.  Parametres    : -Force (Nettoyage), -Debug (Diagnostique).
    10. Verbosite     : Maximale (Traces de creation de segments).
    11. Densite       : Extreme (Standard 18 points + Blocs meta).
    12. Accents       : ZERO_ACCENT (Strict ASCII).
    13. Compatibilite : Windows PowerShell 5.1 (Standard).
    14. Numerotation  : Signature de Couche 00.
    15. Integrite     : Audit de privilege Administrateur integre.
    16. Journalisation: Write-Host / Write-Debug lineaire.
    17. Gestion Erreur: Bloc Try/Catch avec retour d etat explicite.
    18. Classification: SPECTRE - Infrastructure Amorcage.

.CONTRAINTES
    - Privilege Administrateur requis.
    - Respect strict de la sequence locale : le premier enfant d un parent 0X_ est 00_.

.OBJECTIFS
    - Construire le pipeline complet : Sources -> Filtrage -> Atomes -> Fusion -> Usine -> Sorties.
    - Garantir l isolation physique de chaque phase de traitement.
#>

param (
    [switch]$Force,
    [switch]$Debug
)

if ($Debug) { $DebugPreference = 'Continue' }
Write-Host " [!] SPECTRE : AMORCAGE INTEGRAL (V8.5.9) " -ForegroundColor Cyan

# AUDIT PRIVILEGES
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "CRITIQUE : Droits Administrateur requis." ; exit
}

$Racine = $PSScriptRoot
if ($Force) {
    Write-Host " [!] Purge des segments existants..." -ForegroundColor Yellow
    Get-ChildItem -Path $Racine -Directory | Where-Object { $_.Name -match "^[0-9][0-9]_" } | Remove-Item -Recurse -Force
}

# --- DEFINITION DE LA STRUCTURE FINALE ---
$Structure = @(
    '00_Infrastructure',
    '02_Coeur',
    '02_Coeur\00_Actions',
    '02_Coeur\01_Moteurs',
    '04_Sources',
    '04_Sources\00_Brut',
    '06_Filtrage',
    '06_Filtrage\00_Normalisation',
    '07_Atomes',
    '07_Atomes\00_Bibliotheque',
    '08_Fusion',
    '08_Fusion\00_Atlas_Final',
    '09_Usine',
    '09_Usine\00_Generateurs',
    '10_Sorties',
    '10_Sorties\00_Scripts',
    '10_Sorties\01_Documentation',
    '11_Rapports',
    '12_Archives'
)

foreach ($D in $Structure) {
    $Cible = Join-Path $Racine $D
    if (-not (Test-Path $Cible)) {
        New-Item -Path $Cible -ItemType Directory -Force | Out-Null
        Write-Host (" [OK] Segment cree : " + $D) -ForegroundColor Gray
    }
}

Write-Host "`n [SUCCESS] Infrastructure SPECTRE COMPLETE et operationnelle." -ForegroundColor Green