<#
.DESCRIPTION
    1.  Nom          : 00_Referentiel_Ingest.ps1.
    2.  Auteur        : SPECTRE_ENGINE.
    3.  Date          : 26-01-2026.
    4.  Version       : 10.0.1.
    5.  Description   : Ingesteur de referentiels avec auto-creation de l'arborescence.
    6.  Source        : C:\Users\LGE\Mon Drive\PROJETS\EN_COURS\SPECTRE\SPECTRE_V8.0.0\04_Sources\02_Referentiels\.
    7.  Destination   : C:\Users\LGE\Mon Drive\PROJETS\EN_COURS\SPECTRE\SPECTRE_V8.0.0\05_Normalisation\ATLAS_MASTER.txt.
    8.  Dependances   : 00_Infrastructure\00_Configuration.ps1.
    9.  Parametres    : -Debug (Affiche la creation des dossiers et le carving des signatures).
    10. Verbosite     : Haute (Rapport de solidification de l'infrastructure).
    11. Accents       : ZERO_ACCENT (Strict ASCII 7-bit).
    12. Compatibilite : Windows PowerShell 5.1 / Architecture SPECTRE V8.
    13. Numerotation  : Signature Locale 00 (Couche 05).
    14. Integrite     : Verification de l'existence des chemins avant traitement.
    15. Journalisation: Write-Host (Formatage framework SPECTRE).
    16. Gestion Erreur: Creation dynamique des repertoires sources si absents.
    17. Classification: SPECTRE - Ingestion de Sources Autoritaire (CAPE/Unprotect).
    18. Logic_Core    : Scan des fichiers de signatures pour extraction Registry/Files.
    19. Nettoyage     : Unification des ruches et retrait de la prose.
    20. Flux_Donnees  : Acquisition (04) -> Normalisation (05).
    21. Rigueur       : Priorite aux referentiels documentes sur le code brut.
    22. Audit         : Ce script a ete passe a la boucle de conformite (BDC).
    23. Infrastructure: Branche 8.0.0 Sanctuarisee.
    24. Encodage      : Sortie ASCII pure.
    25. Objectif      : Eriger l'Atlas de Verite Master.

.OBJECTIFS
    * Corriger l'absence de dossier dans l'arborescence 04_Sources.
    * Ingerer les signatures de CAPE Sandbox (Referentiel serieux).
    * Centraliser les vecteurs d'evasion identifies par la communaute.

.CONTRAINTES
    * Interdiction totale des caracteres accentues (Zero Accent).
    * Support strict de Windows PowerShell 5.1.
    * Chargement systematique du framework via 00_Configuration.ps1.
#>

param ([switch]$Debug)

if ($Debug) { $DebugPreference = 'Continue' }

# --- 1. CHARGEMENT DU FRAMEWORK ---
$PathRoot = Split-Path $PSScriptRoot -Parent
$PathSPOT = Join-Path $PathRoot '00_Infrastructure\00_Configuration.ps1'
if (Test-Path $PathSPOT) { . $PathSPOT } else { Write-Error "CRITICAL : SPOT absent." ; exit 1 }

Write-Host "`n $($Global:SpectreIHM.Libelle) " -BackgroundColor $Global:SpectreIHM.FondBanniere -ForegroundColor $Global:SpectreIHM.TexteBanniere
Write-Host " [>] INGESTEUR DE REFERENTIELS - FIX ARCHITECTURE (V10.0.1) " -ForegroundColor $Global:SpectreIHM.CouleurPrim

# --- 2. VERIFICATION ET AUTO-CREATION DE L'ARBORESCENCE ---
$SourceRef = "C:\Users\LGE\Mon Drive\PROJETS\EN_COURS\SPECTRE\SPECTRE_V8.0.0\04_Sources\02_Referentiels\"
if (-not (Test-Path $SourceRef)) {
    Write-Host " [!] Dossier source absent. Creation : $SourceRef" -ForegroundColor Yellow
    New-Item -Path $SourceRef -ItemType Directory -Force | Out-Null
}

$DestMaster = Join-Path $PSScriptRoot "ATLAS_MASTER.txt"
$MasterAtlas = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)

# --- 3. MOTEUR D'INGESTION ---
Write-Host " [1/1] Consolidation des sources autoritaires... " -ForegroundColor Cyan

# On cherche les fichiers de signatures (txt, json, py, yara)
$RefFiles = Get-ChildItem -Path $SourceRef -File -Recurse

if ($RefFiles.Count -eq 0) {
    Write-Warning "Le dossier est vide. Placez-y les signatures CAPE ou Unprotect."
}

foreach ($File in $RefFiles) {
    Write-Debug " [INGESTING] Source : $($File.Name)"
    $Content = Get-Content $File.FullName
    foreach ($Line in $Content) {
        # Detection des cles de registre dans les chaines
        if ($Line -match "(?i)(HKLM|HKCU|HKCR|HKU|HKCC|HKEY_LOCAL_MACHINE|HKEY_CURRENT_USER)\\[A-Za-z0-9\\_ -]+") {
            $Match = [regex]::Match($Line, '(?i)(HKLM|HKCU|HKCR|HKU|HKCC|HKEY_LOCAL_MACHINE|HKEY_CURRENT_USER)\\[A-Za-z0-9\\_ -]+').Value
            $Clean = $Match.Replace("HKEY_LOCAL_MACHINE", "HKLM").Replace("HKEY_CURRENT_USER", "HKCU").Trim()
            if ($MasterAtlas.Add($Clean)) {
                Write-Debug " [ATLAS_ADD] $Clean"
            }
        }
    }
}

# --- 4. EXPORTATION ---
$Sorted = $MasterAtlas | Sort-Object
$Sorted | Out-File $DestMaster -Encoding ascii

Write-Host "`n [OK] Atlas Master consolide : $($MasterAtlas.Count) vecteurs identifies." -ForegroundColor Green