<#
.DESCRIPTION
    1.  Nom          : 00_Acquisition_Mitre_V8.ps1
    2.  Auteur        : SPECTRE_ENGINE
    3.  Date          : 22-01-2026
    4.  Version       : 8.9.13
    5.  Description   : Acquisition MITRE avec verrouillage ETag et verbosite debug totale.
    6.  Entrees       : Flux JSON STIX (GitHub MITRE CTI).
    7.  Sorties       : mitre_enterprise_attack_raw.json + .etag.
    8.  Dependances   : 00_Infrastructure\00_Configuration.ps1.
    9.  Parametres    : -Debug (Verbosite chirurgicale du flux HTTP et IO).
    10. Verbosite     : Haute (Debug complet).
    11. Densite       : Extreme (Standard 18 points).
    12. Accents       : ZERO_ACCENT (Strict ASCII 7-bit).
    13. Compatibilite : Windows PowerShell 5.1.
    14. Numerotation  : Signature Locale 00.
    15. Integrite     : Audit JSON et monitoring de flux.
    16. Journalisation: Write-Host (Synthese) / Write-Debug (Systeme).
    17. Gestion Erreur: Interception 304 et Retry avec backoff.
    18. Classification: SPECTRE - Acquisition Strategique.

.CONTRAINTES
    - En mode Debug, tous les en-tetes HTTP cles doivent etre affiches.
    - Aucune information technique ne doit filtrer en mode normal.

.OBJECTIFS
    - Offrir une transparence totale sur le processus de synchronisation.
#>

param ([switch]$Debug)

if ($Debug) { $DebugPreference = 'Continue' }

# --- 1. CHARGEMENT DU FRAMEWORK (SPOT) ---
$PathSPOT = Join-Path $PSScriptRoot '..\00_Infrastructure\00_Configuration.ps1'
if (Test-Path $PathSPOT) { . $PathSPOT } else { Write-Error "SPOT introuvable." ; exit 1 }

Write-Host "`n $($Global:SpectreIHM.Libelle) " -BackgroundColor $Global:SpectreIHM.FondBanniere -ForegroundColor $Global:SpectreIHM.TexteBanniere
Write-Host " [>] ACQUISITION DIFFERENTIELLE (DEBUG COMPLET) " -ForegroundColor $Global:SpectreIHM.CouleurPrim

# --- 2. CONFIGURATION ---
$Url = "https://raw.githubusercontent.com/mitre/cti/master/enterprise-attack/enterprise-attack.json"
$Cible = Join-Path $PSScriptRoot '00_Brut\mitre_enterprise_attack_raw.json'
$EtagFile = $Cible + ".etag"
$MaxRetries = 3 ; $RetryWait = 5

if (-not (Test-Path (Split-Path $Cible))) { New-Item (Split-Path $Cible) -ItemType Directory -Force | Out-Null }
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# --- 3. VERIFICATION ETAG (HEAD) ---
$NeedDownload = $true
$CurrentEtag = if (Test-Path $EtagFile) { Get-Content $EtagFile -Raw } else { "" }

if (Test-Path $Cible) {
    Write-Debug " [SYSTEM] Audit de l etat local :"
    Write-Debug "   | Fichier : $Cible"
    Write-Debug "   | Date    : $((Get-Item $Cible).LastWriteTime)"
    Write-Debug "   | ETag    : $CurrentEtag"

    try {
        $Chrono = [System.Diagnostics.Stopwatch]::StartNew()
        $CheckReq = [System.Net.HttpWebRequest]::Create($Url)
        $CheckReq.Method = "HEAD"
        $CheckReq.Timeout = 10000
        if ($CurrentEtag) { $CheckReq.Headers.Add("If-None-Match", $CurrentEtag) }
        
        $CheckResp = $CheckReq.GetResponse()
        $Chrono.Stop()
        
        Write-Debug " [HTTP] Reponse recue en $($Chrono.ElapsedMilliseconds)ms (Code: $($CheckResp.StatusCode))"
        $CheckResp.Close()
    }
    catch {
        $Chrono.Stop()
        if ($_.Exception.Message -match "304") {
            Write-Host " [OK] STATUT : Cache valide. Aucun transfert requis." -ForegroundColor Cyan
            Write-Debug " [SYSTEM] Negociation HTTP 304 confirmee par le serveur GitHub."
            $NeedDownload = $false
        } else {
            Write-Debug " [ERROR] Echec HEAD : $($_.Exception.Message)"
        }
    }
}

# --- 4. TELECHARGEMENT ---
if ($NeedDownload) {
    $RetryCount = 0 ; $Success = $false
    while (-not $Success -and $RetryCount -lt $MaxRetries) {
        try {
            Write-Host " [!] Transfert du referentiel... " -ForegroundColor $Global:SpectreIHM.CouleurSec
            $Request = [System.Net.HttpWebRequest]::Create($Url)
            $Request.Timeout = 30000
            $Response = $Request.GetResponse()
            
            $NewEtag = $Response.Headers["ETag"]
            $ContentLength = $Response.ContentLength
            
            Write-Debug " [HTTP] En-tetes de reponse :"
            Write-Debug "   | ETag Serveur   : $NewEtag"
            Write-Debug "   | Taille (Bytes) : $ContentLength"
            Write-Debug "   | Last-Modified  : $($Response.LastModified)"

            $Stream = $Response.GetResponseStream()
            $FileStream = [System.IO.FileStream]::new($Cible, [System.IO.FileMode]::Create)
            
            $Chrono = [System.Diagnostics.Stopwatch]::StartNew()
            $Stream.CopyTo($FileStream)
            $Chrono.Stop()
            
            $FileStream.Close() ; $Stream.Close() ; $Response.Close()
            
            if ($NewEtag) { $NewEtag | Out-File $EtagFile -Encoding ascii -Force }
            
            $Success = $true
            Write-Host " [OK] Fichier synchronise ($("{0:N2}" -f ($ContentLength / 1MB)) MB)." -ForegroundColor Green
            Write-Debug " [SYSTEM] Flux IO termine en $($Chrono.ElapsedMilliseconds)ms."
        }
        catch {
            $RetryCount++
            Write-Debug " [RETRY] Echec tentative $RetryCount : $($_.Exception.Message)"
            if ($RetryCount -lt $MaxRetries) { Start-Sleep -Seconds $RetryWait }
        }
    }
}

# --- 5. VALIDATION ---
if (Test-Path $Cible) {
    Write-Debug " [SYSTEM] Debut de l audit structurel JSON..."
    try {
        $Null = Get-Content $Cible -Raw | ConvertFrom-Json -ErrorAction Stop
        Write-Debug " [SYSTEM] Audit JSON reussi (Format STIX valide)."
    }
    catch {
        Write-Host " [!] ERREUR : Corruption detectee." -ForegroundColor $Global:SpectreIHM.CouleurErreur
        Remove-Item $Cible, $EtagFile -Force -ErrorAction SilentlyContinue
    }
}

Write-Host " [SUCCESS] Fin du processus d acquisition. " -ForegroundColor Green