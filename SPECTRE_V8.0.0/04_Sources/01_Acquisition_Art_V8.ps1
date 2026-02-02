<#
.DESCRIPTION
    1.  Nom          : 01_Acquisition_Art_V8.ps1
    2.  Auteur        : SPECTRE_ENGINE
    3.  Date          : 22-01-2026
    4.  Version       : 8.9.27
    5.  Description   : Acquisition recursive de l arborescence /atomics/ via API GitHub.
    6.  Entrees       : API GitHub (redcanaryco/atomic-red-team).
    7.  Sorties       : Structure TXXXX\TXXXX.yaml dans 04_Sources\00_Brut\atomics.
    8.  Dependances   : 00_Infrastructure\00_Configuration.ps1.
    9.  Parametres    : -Debug (Affichage des transactions API et IO).
    10. Verbosite     : Haute (Suivi de progression par technique).
    11. Densite       : Extreme (Standard 18 points).
    12. Accents       : ZERO_ACCENT (Strict ASCII 7-bit).
    13. Compatibilite : Windows PowerShell 5.1.
    14. Numerotation  : Signature Locale 01 (Couche 04).
    15. Integrite     : Verification de l existence des fichiers YAML distants.
    16. Journalisation: Write-Host (Progression) / Write-Debug (API/ETag).
    17. Gestion Erreur: Arret sur quota API depasse, bypass sur YAML manquants.
    18. Classification: SPECTRE - Acquisition Massive de TTPs.

.CONTRAINTES
    - Doit reconstruire la structure de dossier locale pour chaque TID.
    - Utilisation imperative de l API GitHub pour l enumeration.
    - Interdiction totale des caracteres accentues.

.OBJECTIFS
    - Recuperer l integralite des fichiers YAML individuels pour forger l Atlas.
    - Minimiser la consommation de bande passante via la gestion des ETag.
#>

param ([switch]$Debug)

if ($Debug) { $DebugPreference = 'Continue' }

# --- 1. CHARGEMENT DU FRAMEWORK (SPOT) ---
$PathSPOT = Join-Path $PSScriptRoot '..\00_Infrastructure\00_Configuration.ps1'
if (Test-Path $PathSPOT) { 
    . $PathSPOT 
} else { 
    Write-Error "ERREUR : Framework SPECTRE (SPOT) introuvable." ; exit 1 
}

Write-Host "`n $($Global:SpectreIHM.Libelle) " -BackgroundColor $Global:SpectreIHM.FondBanniere -ForegroundColor $Global:SpectreIHM.TexteBanniere
Write-Host " [>] ACQUISITION RECURSIVE : THE PRECIOUS (ART ATOMICS) " -ForegroundColor $Global:SpectreIHM.CouleurPrim

# --- 2. CONFIGURATION API ---
$ApiBase = "https://api.github.com/repos/redcanaryco/atomic-red-team/contents/atomics"
$DestRoot = Join-Path $PSScriptRoot '00_Brut\atomics'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not (Test-Path $DestRoot)) { 
    Write-Debug " [DEBUG] Creation de la racine atomique : $DestRoot"
    New-Item $DestRoot -ItemType Directory -Force | Out-Null 
}

# --- 3. DECOUVERTE DES DOSSIERS TECHNIQUES (TXXXX) ---
Write-Host " [!] Interrogation de l arborescence distante (API GitHub)... " -ForegroundColor $Global:SpectreIHM.CouleurSec
try {
    $Folders = Invoke-RestMethod -Uri $ApiBase -Method Get -Headers @{"User-Agent"="SPECTRE-ENGINE-V8"}
}
catch {
    Write-Host " [!] ERREUR API (Quota ou Reseau) : $($_.Exception.Message)" -ForegroundColor $Global:SpectreIHM.CouleurErreur
    exit 1
}

# --- 4. SYNCHRONISATION DES FICHIERS ---
$FoldersList = $Folders | Where-Object { $_.type -eq "dir" -and $_.name -match "^T\d" }
$Total = $FoldersList.Count
$Current = 0

Write-Host " [!] Debut de la synchronisation de $Total techniques... " -ForegroundColor $Global:SpectreIHM.CouleurSec

foreach ($Folder in $FoldersList) {
    $Current++
    $TID = $Folder.name
    $LocalFolder = Join-Path $DestRoot $TID
    $YamlFile = "$TID.yaml"
    $RawUrl = "https://raw.githubusercontent.com/redcanaryco/atomic-red-team/master/atomics/$TID/$YamlFile"
    $TargetPath = Join-Path $LocalFolder $YamlFile
    $EtagPath = $TargetPath + ".etag"

    if (-not (Test-Path $LocalFolder)) { New-Item $LocalFolder -ItemType Directory -Force | Out-Null }

    # Verification ETag pour optimiser le transfert
    $NeedDownload = $true
    if (Test-Path $TargetPath) {
        $CheckReq = [System.Net.HttpWebRequest]::Create($RawUrl)
        $CheckReq.Method = "HEAD"
        if (Test-Path $EtagPath) {
            $SavedEtag = Get-Content $EtagPath -Raw
            $CheckReq.Headers.Add("If-None-Match", $SavedEtag)
            Write-Debug " [DEBUG] $TID : Verification ETag local ($SavedEtag)"
        }
        try {
            $Resp = $CheckReq.GetResponse()
            $Resp.Close()
        } catch {
            if ($_.Exception.Message -match "304") { 
                $NeedDownload = $false 
                Write-Debug " [DEBUG] $TID : Cache valide (304)."
            }
        }
    }

    # Execution du transfert si necessaire
    if ($NeedDownload) {
        Write-Host " [$Current/$Total] Synchronisation : $TID " -ForegroundColor Cyan
        try {
            $Req = [System.Net.HttpWebRequest]::Create($RawUrl)
            $Req.Timeout = 10000
            $Resp = $Req.GetResponse()
            $NewEtag = $Resp.Headers["ETag"]
            
            $Stream = $Resp.GetResponseStream()
            $Fs = [System.IO.FileStream]::new($TargetPath, [System.IO.FileMode]::Create)
            $Stream.CopyTo($Fs)
            $Fs.Close() ; $Stream.Close() ; $Resp.Close()
            
            if ($NewEtag) { $NewEtag | Out-File $EtagPath -Encoding ascii -Force }
            Write-Debug " [DEBUG] $TID : Telechargement OK (Nouveau ETag: $NewEtag)"
        } catch {
            Write-Debug " [DEBUG] $TID : Erreur ou fichier absent ($($_.Exception.Message))"
        }
    }
}

Write-Host " [SUCCESS] Arborescence /atomics/ synchronisee avec succes. " -ForegroundColor Green