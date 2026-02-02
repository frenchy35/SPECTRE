<#
.DESCRIPTION
    1.  Nom          : 02_Collecte_Sources_AntiVM_V8.ps1
    2.  Auteur        : SPECTRE_ENGINE
    3.  Date          : 23-01-2026
    4.  Version       : 8.9.84
    5.  Description   : Collecteur intelligent optimise (SHA-Check) avec gestion d'erreur Substring.
    6.  Entrees       : API GitHub (Commit SHA) et Archives ZIP.
    7.  Sorties       : Synchronisation dans 04_Sources\02_AntiVM_Raw\.
    8.  Dependances   : 00_Infrastructure\00_Configuration.ps1.
    9.  Parametres    : -Debug (Suivi des echanges API et signatures).
    10. Verbosite     : Haute (Rapport de delta securise).
    11. Densite       : Maximale (Standard 18 points).
    12. Accents       : ZERO_ACCENT (Strict ASCII 7-bit).
    13. Compatibilite : Windows PowerShell 5.1.
    14. Numerotation  : Signature Locale 02 (Couche 04).
    15. Integrite     : Securisation des affichages de hash vides.
    16. Journalisation: Write-Host (Couleurs SPECTRE).
    17. Gestion Erreur: Verification de longueur de chaine avant Substring.
    18. Classification: SPECTRE - Ingestion Robuste.

.CONTRAINTES
    - Interdiction totale de caracteres accentues dans le code et les logs.
    - Utilisation obligatoire du framework SPOT pour l'IHM.

.OBJECTIFS
    - Reduire la consommation reseau en verifiant le commit SHA distant.
    - Garantir une extraction propre sans sous-dossiers parasites.
#>

param ([switch]$Debug)

if ($Debug) { $DebugPreference = 'Continue' }

# --- 1. CHARGEMENT DU FRAMEWORK ---
$PathSPOT = Join-Path $PSScriptRoot '..\00_Infrastructure\00_Configuration.ps1'
if (Test-Path $PathSPOT) { 
    . $PathSPOT 
} else { 
    Write-Error "SPOT introuvable. Structure SPECTRE non detectee." ; exit 1 
}

Write-Host "`n $($Global:SpectreIHM.Libelle) " -BackgroundColor $Global:SpectreIHM.FondBanniere -ForegroundColor $Global:SpectreIHM.TexteBanniere
Write-Host " [>] COLLECTEUR ANTI-VM : OPTIMISATION BANDE PASSANTE (V8.9.84) " -ForegroundColor $Global:SpectreIHM.CouleurPrim

# --- 2. CONFIGURATION ---
$BaseDir = Join-Path $PSScriptRoot "02_AntiVM_Raw"
if (-not (Test-Path $BaseDir)) { New-Item $BaseDir -ItemType Directory -Force | Out-Null }

$Sources = @(
    @{ Name="Pafish"     ; Owner="a0rtega"       ; Repo="pafish"      ; Branch="master" }
    @{ Name="AlKhaser"   ; Owner="LordNoteworthy" ; Repo="al-khaser"   ; Branch="master" }
    @{ Name="Uranium235" ; Owner="hfiref0x"       ; Repo="UACMe"       ; Branch="master" }
)

# --- 3. EXECUTION ---
foreach ($S in $Sources) {
    Write-Host "`n [>] Source : $($S.Name) " -ForegroundColor Cyan
    
    $LocalPath  = Join-Path $BaseDir $S.Name
    $SyncFile   = Join-Path $LocalPath ".spectre_sync"
    $ZipUrl     = "https://github.com/$($S.Owner)/$($S.Repo)/archive/refs/heads/$($S.Branch).zip"
    $ApiUrl     = "https://api.github.com/repos/$($S.Owner)/$($S.Repo)/commits/$($S.Branch)"
    
    # A. Recuperation du SHA distant (API)
    $RemoteSHA = "Unknown"
    try {
        Write-Debug "Interrogation API GitHub : $ApiUrl"
        $Response = Invoke-RestMethod -Uri $ApiUrl -Method Get -Headers @{"User-Agent"="SPECTRE_ENGINE"}
        $RemoteSHA = $Response.sha
    } catch {
        Write-Warning "Impossible de contacter l'API pour $($S.Name). Verification differee."
    }

    # B. Recuperation du SHA local
    $LocalSHA = ""
    if (Test-Path $SyncFile) { $LocalSHA = (Get-Content $SyncFile -Raw).Trim() }

    # C. Verification de conformite
    if ($LocalSHA -eq $RemoteSHA -and $RemoteSHA -ne "Unknown") {
        $DisplaySHA = if ($RemoteSHA.Length -ge 8) { $RemoteSHA.Substring(0,8) } else { $RemoteSHA }
        Write-Host "     [OK] Source a jour (SHA: $DisplaySHA)." -ForegroundColor Green
        continue
    }

    # D. Affichage du Delta Securise
    $ShortLocal  = if ($LocalSHA.Length -ge 8) { $LocalSHA.Substring(0,8) } else { "None" }
    $ShortRemote = if ($RemoteSHA.Length -ge 8) { $RemoteSHA.Substring(0,8) } else { "Unknown" }

    Write-Host "     [!] Difference detectee (Local: $ShortLocal -> Distant: $ShortRemote)" -ForegroundColor Yellow
    $Choice = Read-Host "     Accepter le telechargement ? (O/N/Stop)"
    
    if ($Choice -eq 'Stop') { break }
    if ($Choice -eq 'O' -or $Choice -eq 'y') {
        $ZipPath = Join-Path $BaseDir "$($S.Name).zip"
        
        Write-Host "     [1/2] Flux reseau... " -NoNewline -ForegroundColor Gray
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath -ErrorAction Stop
            Write-Host "OK" -ForegroundColor Green

            Write-Host "     [2/2] Deploiement... " -NoNewline -ForegroundColor Gray
            if (Test-Path $LocalPath) { Remove-Item $LocalPath -Recurse -Force }
            Expand-Archive -Path $ZipPath -DestinationPath $LocalPath -Force
            
            # Normalisation de l'extraction (GitHub Wrapper Folder)
            $InnerDir = Get-ChildItem -Path $LocalPath -Directory | Select-Object -First 1
            if ($InnerDir) {
                Move-Item -Path "$($InnerDir.FullName)\*" -Destination $LocalPath -Force
                Remove-Item $InnerDir.FullName -Recurse -Force
            }

            Remove-Item $ZipPath -Force
            $RemoteSHA | Out-File $SyncFile -Encoding ascii
            Write-Host "TERMINE" -ForegroundColor Green
        }
        catch {
            Write-Host "ERREUR" -ForegroundColor Red
            Write-Debug "Details technique : $_"
        }
    } else {
        Write-Host "     [-] Synchronisation ignoree." -ForegroundColor Gray
    }
}

Write-Host "`n [SUCCESS] Flux d'acquisition cloture." -ForegroundColor Green