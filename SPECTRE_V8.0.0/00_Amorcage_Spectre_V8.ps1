<#
.DESCRIPTION
    1.  Nom          : 00_Amorcage_Spectre_V8.ps1
    2.  Auteur        : SPECTRE_ENGINE
    3.  Date          : 22-01-2026
    4.  Version       : 8.6.4
    5.  Description   : Initialise l infrastructure avec interaction operateur obligatoire avant purge.
    6.  Entrees       : Confirmation O/N de l operateur.
    7.  Sorties       : Arborescence physique (00 a 15).
    8.  Dependances   : Windows PowerShell 5.1 / Privileges Admin.
    9.  Parametres    : -Force (Purge avec alerte), -Debug (Diagnostique).
    10. Verbosite     : Maximale.
    11. Densite       : Extreme (Standard 18 points + Blocs meta).
    12. Accents       : ZERO_ACCENT (Strict ASCII).
    13. Compatibilite : Windows PowerShell 5.1.
    14. Numerotation  : Signature de Couche 00.
    15. Integrite     : Protection des scripts racine et validation humaine.
    16. Journalisation: Write-Host / Write-Debug.
    17. Gestion Erreur: Arret si refus operateur.
    18. Classification: SPECTRE - Infrastructure Amorcage.

.CONTRAINTES
    - Demande une confirmation explicite si des dossiers existent deja.
    - Bloque l execution si l utilisateur ne repond pas 'O' en mode Force.

.OBJECTIFS
    - Eviter toute perte de donnee accidentelle par une execution trop rapide.
    - Informer l operateur de l etat reel de l infrastructure avant action.
#>

param (
    [switch]$Force,
    [switch]$Debug
)

if ($Debug) { $DebugPreference = 'Continue' }
Write-Host " `n [!] SPECTRE : AMORCAGE INTERACTIF (V8.6.4) " -BackgroundColor Cyan -ForegroundColor Black

# --- 1. AUDIT PRIVILEGES ---
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "CRITIQUE : Droits Administrateur requis." ; exit
}

# --- 2. CONFIGURATION ---
$Racine = $PSScriptRoot
$Exclusions = @("00_Amorcage_Spectre_V8.ps1", "01_Gestion_Documentation_V8.ps1", "00_Configuration.ps1")
$Structure = @(
    '00_Infrastructure','01_Gestion','01_Gestion\00_Helpers','01_Gestion\01_Templates',
    '02_Coeur','02_Coeur\00_Actions','02_Coeur\01_Moteurs',
    '03_Sandbox','03_Sandbox\00_Tests',
    '04_Sources','04_Sources\00_Brut',
    '05_Normalisation','05_Normalisation\00_Maps',
    '06_Filtrage','06_Filtrage\00_Clean',
    '07_Atomes','07_Atomes\00_Library',
    '08_Fusion','08_Fusion\00_Consolidation',
    '09_Usine','10_Sorties','10_Sorties\00_Deploy','10_Sorties\01_Doc',
    '11_Runtime','11_Runtime\00_State',
    '12_Archives','13_Traductions','14_Logs','15_Audit'
)

# --- 3. ANALYSE DE L ETAT ACTUEL ---
$DossiersExistants = Get-ChildItem -Path $Racine -Directory | Where-Object { $_.Name -match "^[0-9][0-9]_" }
if ($DossiersExistants) {
    Write-Host " [!] ATTENTION : Une infrastructure SPECTRE a ete detectee." -ForegroundColor Yellow
    if (-not $Force) {
        $Choix = Read-Host " Dossiers presents. Voulez-vous completer l'arborescence sans rien effacer ? (O/N)"
        if ($Choix -notmatch "O") { Write-Host " [!] Annulation par l'operateur." ; exit }
    }
}

# --- 4. GESTION CRITIQUE DU MODE FORCE ---
if ($Force) {
    Write-Host " [!!!] ALERTE DE SECURITE : MODE PURGE ACTIVE [!!!] " -BackgroundColor Red -ForegroundColor White
    Write-Host " Cette action va supprimer TOUS les dossiers numerotes et les scripts non-proteges." -ForegroundColor Red
    $Confirm = Read-Host " CONFIRMER LA DESTRUCTION TOTALE ? (Ecrire 'CONFIRMER' pour continuer)"
    
    if ($Confirm -eq "CONFIRMER") {
        Write-Host " [!] Purge en cours..." -ForegroundColor Yellow
        # Suppression dossiers
        $DossiersExistants | Remove-Item -Recurse -Force
        # Suppression fichiers racine non-exclus
        Get-ChildItem -Path $Racine -File -Filter "*.ps1" | ForEach-Object {
            if ($Exclusions -notcontains $_.Name) { Remove-Item $_.FullName -Force }
        }
    } else {
        Write-Host " [!] Purge annulee. Passage en mode installation standard." -ForegroundColor Cyan
    }
}

# --- 5. CREATION DES SEGMENTS ---
Write-Host " [!] Lancement du deploiement de l'arborescence..." -ForegroundColor Cyan
foreach ($D in $Structure) {
    $Cible = Join-Path $Racine $D
    if (-not (Test-Path $Cible)) {
        try {
            New-Item -Path $Cible -ItemType Directory -Force | Out-Null
            Write-Host (" [+] Segment installe : " + $D) -ForegroundColor Gray
        } catch {
            Write-Error (" [!] Erreur sur : " + $D)
        }
    } else {
        Write-Debug (" [DEBUG] Deja present : " + $D)
    }
}

Write-Host "`n [SUCCESS] Infrastructure SPECTRE prete pour l'operateur." -ForegroundColor Green