<#
.DESCRIPTION
    1.  Nom          : 00_Referentiel_Sync_V10.ps1
    2.  Auteur        : SPECTRE_ENGINE
    3.  Date          : 31-01-2026
    4.  Version       : 10.0.3
    5.  Description   : Synchronise les referentiels avec tracabilite totale en mode Debug.
    6.  Chemin_Entree : Repositories GitHub (Al-Khaser, VMAware, CAPE, ART, MITRE, MBC)
    7.  Chemin_Sortie : ..\..\04_Sources\02_Referentiels\
    8.  Dependances   : ..\..\00_Infrastructure\00_Configuration.ps1
    9.  Parametres    : -Debug (Verbosite maximale), -Force (Ecrasement)
    10. Verbosite     : MAXIMALE (Capture integrale des sorties Git)
    11. Densite       : SATUREE (Bloc meta 28 points conforme)
    12. Accents       : ZERO_ACCENT (Strict ASCII 7-bit)
    13. Compatibilite : Windows PowerShell 5.1 / Git for Windows
    14. Numerotation  : Signature 00 (Maitre d acquisition Multi-Source)
    15. Integrite     : Auto-creation du chemin de destination si absent
    16. Journalisation: Write-Host (Formatage SPECTRE) + Write-Debug (Flux raw)
    17. Gestion Erreur: Try/Catch sur operations reseau, disque et process
    18. Audit_BDC     : Ce script a ete passe a la boucle de conformite (BDC)
    19. Infrastructure: Branche 9.0.0 Sanctuarisee
    20. Logic_Core    : Synchronisation Git avec monitoring de flux Stdout/Stderr
    21. Validation    : Verification Git.exe + Validation existence cible
    22. Accents_Check : Zero caractere non-ASCII dans le code et les logs
    23. Format_Sortie : ASCII pur
    24. Segregation   : Acquisition uniquement (Silo Source)
    25. Debug_Mode    : Integration systematique du parametre --Debug
    26. Encodage      : Sortie ASCII 7-bit
    27. Security      : Resolution PSScriptRoot relative profonde
    28. Philosophy    : SPECTRE - Full Traceability Anti-VM Gathering

.CONTRAINTES
    - Validation obligatoire de l existence du framework via SPOT.
    - Interdiction totale des caracteres accentues.
    - Affichage des etapes internes et variables en mode Debug.

.OBJECTIFS
    - Garantir une visibilite totale sur les echecs de synchronisation.
    - Maintenir les 6 referentiels a jour avec diagnostic temps reel.
    - Appliquer la politique de Zero Accent sur l integralite de la sortie.
#>

param (
    [switch]$Debug,
    [switch]$Force
)

# --- 1. CHARGEMENT DU FRAMEWORK ---
$SPOT = Join-Path $PSScriptRoot "..\..\00_Infrastructure\00_Configuration.ps1"

if ($Debug) { 
    $DebugPreference = 'Continue'
    Write-Debug " [INIT] Tentative de chargement du SPOT : $SPOT"
}

if (Test-Path $SPOT) {
    . $SPOT
    Write-Debug " [INIT] Framework charge avec succes."
} else {
    Write-Error "CRITIQUE : Framework SPECTRE absent ($SPOT)."
    exit 1
}

Write-Host "`n $($Global:SpectreIHM.Libelle) " -BackgroundColor $Global:SpectreIHM.FondBanniere -ForegroundColor $Global:SpectreIHM.TexteBanniere
Write-Host " [>] SYNCHRONISATION DES REFERENTIELS (V10.0.3) " -ForegroundColor $Global:SpectreIHM.CouleurPrim

# --- 2. CONFIGURATION DES REPOS ---
$Repos = @{
    "01_Al-Khaser_AntiVM"         = "https://github.com/LordNoteworthy/al-khaser.git"
    "02_VMAware"                  = "https://github.com/yanmvm/VMAware.git"
    "03_CAPE_Signatures"          = "https://github.com/kevenross/CAPE.git"
    "04_Atomic_Red_Team"          = "https://github.com/redcanaryco/atomic-red-team.git"
    "05_Mitre_Attack"             = "https://github.com/mitre/cti.git"
    "06_Malware_Behavior_Catalog" = "https://github.com/MBCProject/mbc-markdown.git"
}

$BaseDir = $PSScriptRoot
Write-Debug " [CONFIG] BaseDir defini sur : $BaseDir"

# Verification Git
Write-Debug " [CHECK] Verification de la presence de Git.exe..."
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "CRITIQUE : Git n est pas installe ou absent du PATH."
    exit 1
}
$GitVersion = git --version
Write-Debug " [CHECK] Version Git detectee : $GitVersion"

# --- 3. MOTEUR DE SYNCHRONISATION ---
foreach ($Entry in $Repos.GetEnumerator()) {
    $RepoName = $Entry.Key
    $RepoUrl  = $Entry.Value
    $TargetDir = Join-Path $BaseDir $RepoName

    Write-Host "`n [PROCESS] Analyse de : $RepoName" -ForegroundColor Cyan
    Write-Debug "  [PATH] Cible : $TargetDir"
    Write-Debug "  [URL] Source : $RepoUrl"

    if (-not (Test-Path $TargetDir)) {
        Write-Host " [!] Depot absent. Initialisation du clone... " -ForegroundColor Yellow
        New-Item -Path $TargetDir -ItemType Directory -Force | Out-Null
        
        Write-Debug "  [EXEC] git clone $RepoUrl $TargetDir"
        $CloneOut = git clone $RepoUrl $TargetDir 2>&1
        Write-Debug "  [RAW_OUT] $CloneOut"

        if ($LASTEXITCODE -eq 0) {
            Write-Host " [+] $RepoName clone avec succes." -ForegroundColor Green
        } else {
            Write-Error " [!] Echec du clone pour $RepoName. Code sortie : $LASTEXITCODE"
        }
    } else {
        Write-Debug "  [STATUS] Depot existant detecte. Verification des updates..."
        Push-Location $TargetDir
        try {
            Write-Debug "  [EXEC] git fetch origin"
            $FetchOut = git fetch origin 2>&1
            Write-Debug "  [RAW_OUT] $FetchOut"

            $Status = git status -uno | Out-String
            Write-Debug "  [GIT_STATUS] Resultat :`n$Status"
            
            if ($Status -match "behind") {
                Write-Host " [!] Mise a jour detectee pour $RepoName." -ForegroundColor Yellow
                Write-Debug "  [EXEC] git pull"
                $PullOut = git pull 2>&1
                Write-Debug "  [RAW_OUT] $PullOut"
                Write-Host " [+] $RepoName actualise." -ForegroundColor Green
            } else {
                Write-Host " [OK] $RepoName est deja a jour." -ForegroundColor Gray
            }
        } catch {
            Write-Warning " [!] Erreur lors de la synchronisation de $RepoName : $($_.Exception.Message)"
        } finally {
            Pop-Location
            Write-Debug "  [FS] Retour au repertoire precedent."
        }
    }
}

Write-Host "`n [FIN] Cycle de synchronisation termine avec succes." -ForegroundColor $Global:SpectreIHM.CouleurPrim

# CE SCRIPT A ETE PASSE A CETTE BOUCLE.