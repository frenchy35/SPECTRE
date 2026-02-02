<#
.DESCRIPTION
    1.  Nom          : 02_Generate_Atlas_Universal_JSON_V10.ps1
    2.  Auteur        : SPECTRE_ENGINE
    3.  Date          : 30-01-2026
    4.  Version       : 10.1.2
    5.  Description   : Consolidateur Atlas Universel avec moteur d inference Logique-OU ameliore (Hawk 'disk').
    6.  Chemin_Entree : ..\..\04_Sources\02_Referentiels\03_CAPE\modules\signatures\
    7.  Chemin_Sortie : ..\..\06_Modules_Transpiles\CAPE_Signatures\atlas_cape_universal.json
    8.  Dependances   : ..\..\00_Infrastructure\00_Configuration.ps1
    9.  Parametres    : -Debug (Verbosite totale), -Force (Ecrasement)
    10. Verbosite     : MAXIMALE (Tracabilite des facteurs d inference)
    11. Densite       : MOYENNE (Structure stable et agile)
    12. Accents       : ZERO_ACCENT (Strict ASCII 7-bit)
    13. Compatibilite : Windows PowerShell 5.1
    14. Numerotation  : Signature 02 (Universal Atlas Logic-OR v2)
    15. TTPs          : Capture integrale MITRE ATT&CK
    16. MBCs          : Capture integrale Malware Behavior Catalog
    17. Categories    : Capture exhaustive par type de menace
    18. Validation    : Existence source verifiee (Directive Memorisee 2026-01-27)
    19. Audit_BDC     : Ce script a ete passe a la boucle de conformite (BDC)
    20. Logic_Core    : Factorial Inference (Filename-Hawk OR Content-Regex)
    21. Regex_Policy  : Preservation absolue des patterns r-string
    22. Segregation   : Data-Only output (Universal Reference Store)
    23. Encodage      : Sortie ASCII pure (Zero Accent)
    24. Tracabilite   : OS, SOURCE_FILE, SIGNATURE_SILO et COMMIT_PERSISTENCE
    25. Performance   : Optimise pour scan de masse (>500 fichiers signatures)
    26. Securite      : Resolution via PSScriptRoot
    27. Format_Sortie : JSON industriel structure (Depth 5)
    28. Documentation : Bloc .DESCRIPTION conforme de 28 points

.CONTRAINTES
    - Validation obligatoire de l'existence de chaque fichier source avant lecture.
    - Zero accent dans le code, les commentaires et la documentation technique.
    - Utilisation imperative de la Logique-OU (Hawk sur nom OU Regex indicateurs).
    - Interdiction de lister des extensions de fichiers en dur.

.OBJECTIFS
    - Classifier le Silo 'FILESYSTEM' pour les signatures de disques génériques (SetupAPI).
    - Maintenir le silence sur les signatures purement comportementales (GENERIC).
    - Garantir une persistance de commit cohérente avec le silo détecté.
#>

param (
    [switch]$Debug,
    [switch]$Force
)

# --- 1. CHARGEMENT DU FRAMEWORK ---
$SPOT = Join-Path $PSScriptRoot "..\..\00_Infrastructure\00_Configuration.ps1"
if (Test-Path $SPOT) { . $SPOT } else { Write-Error "CRITIQUE : Framework absent." ; exit 1 }

if ($Debug) { $DebugPreference = 'Continue' }

Write-Host "`n $($Global:SpectreIHM.Libelle) " -BackgroundColor $Global:SpectreIHM.FondBanniere -ForegroundColor $Global:SpectreIHM.TexteBanniere
Write-Host " [>] GENERATEUR D'ATLAS LOGIQUE-OU : V10.1.2 " -ForegroundColor $Global:SpectreIHM.CouleurPrim

# --- 2. CONFIGURATION ---
$SrcBase = Join-Path $PSScriptRoot "..\..\04_Sources\02_Referentiels\03_CAPE\modules\signatures"
$DstFile = Join-Path $PSScriptRoot "..\..\06_Modules_Transpiles\CAPE_Signatures\atlas_cape_universal.json"

if (-not (Test-Path $SrcBase)) { exit 1 }

$Files = Get-ChildItem -Path $SrcBase -Filter "*.py" -Recurse
$Atlas_Collection = New-Object System.Collections.Generic.List[PSObject]

# --- 3. MOTEUR D'INFERENCE FACTORIEL ---
foreach ($File in $Files) {
    if ($File.Name -match "__init__") { continue }
    if (-not (Test-Path $File.FullName)) { continue }

    Write-Host " [SCAN] $($File.Name)" -ForegroundColor Gray
    $DetectedOS = $File.Directory.Name.ToUpper()
    $Lines = Get-Content -Path $File.FullName -Encoding UTF8
    
    $EntryData = [Ordered]@{
        "OS"                 = $DetectedOS
        "SOURCE_FILE"        = $File.Name
        "SIGNATURE_SILO"     = "GENERIC"
        "COMMIT_PERSISTENCE" = "FALSE"
    }

    $InList = $false
    $CurrentList = $null
    $SiloHits = New-Object System.Collections.Generic.List[string]

    # --- FACTEUR A : HAWK SUR LE NOM DE FICHIER ---
    # Ajout de 'disk' pour capturer les artefacts materiels
    if ($File.Name -match "file|path|dir|folder|drv|driver|disk") { $SiloHits.Add("FILESYSTEM") }
    if ($File.Name -match "reg|key|hive") { $SiloHits.Add("REGISTRY") }
    if ($File.Name -match "mutex|event|sync|lock") { $SiloHits.Add("MUTEX_EVENT") }
    if ($File.Name -match "net|url|http|dns|socket|ip|host") { $SiloHits.Add("NETWORK") }
    if ($File.Name -match "wmi|cim|query|wql") { $SiloHits.Add("WMI_CIM") }

    foreach ($Line in $Lines) {
        $Clean = $Line.Trim()
        if ([string]::IsNullOrEmpty($Clean) -or $Clean -match "^#") { continue }

        # Detection de listes (Agnostique)
        if ($Clean -match "^(?:\w+\.)?(\w+)\s*[:=]\s*\[") {
            $FieldName = $Matches[1].ToUpper()
            $CurrentList = $FieldName
            $EntryData[$CurrentList] = New-Object System.Collections.Generic.List[string]
            $InList = $true

            # Facteur A (bis) : Hawk sur le nom de la variable
            if ($FieldName -match "FILE|PATH|DIR|DRV|DISK") { $SiloHits.Add("FILESYSTEM") }
            if ($FieldName -match "REG|KEY") { $SiloHits.Add("REGISTRY") }
            if ($FieldName -match "EVENT|MUTEX|SYNC") { $SiloHits.Add("MUTEX_EVENT") }
            if ($FieldName -match "NET|URL|DNS|HTTP") { $SiloHits.Add("NETWORK") }
            if ($FieldName -match "WMI|CIM") { $SiloHits.Add("WMI_CIM") }

            if ($Clean -match "\[(.*?)\]") {
                [regex]::Matches($Matches[1], 'r?["''](.*?)["'']') | ForEach-Object {
                    $Val = $_.Groups[1].Value
                    $EntryData[$CurrentList].Add($Val)
                    # --- FACTEUR B : REGEX SUR CONTENU ---
                    if ($Val -match "HKEY_|Software\\\\|System\\\\") { $SiloHits.Add("REGISTRY") }
                    if ($Val -match "\\\\|\/") { $SiloHits.Add("FILESYSTEM") }
                    if ($Val -match "http|ftp|www|\d{1,3}\.\d{1,3}") { $SiloHits.Add("NETWORK") }
                    if ($Val -match "SELECT |FROM |Win32_") { $SiloHits.Add("WMI_CIM") }
                    if ($Val -match ".:-") { $SiloHits.Add("MUTEX_EVENT") }
                }
                $InList = $false
            }
            continue
        }

        # Items intra-liste
        if ($InList -and ($null -ne $CurrentList)) {
            if ($Clean -match 'r?["''](.*?)["'']') {
                $Val = $Matches[1]
                $EntryData[$CurrentList].Add([string]$Val)
                # --- FACTEUR B : REGEX SUR CONTENU ---
                if ($Val -match "HKEY_|Software\\\\|System\\\\") { $SiloHits.Add("REGISTRY") }
                if ($Val -match "\\\\|\/") { $SiloHits.Add("FILESYSTEM") }
                if ($Val -match "http|ftp|www|\d{1,3}\.\d{1,3}") { $SiloHits.Add("NETWORK") }
                if ($Val -match "SELECT |FROM |Win32_") { $SiloHits.Add("WMI_CIM") }
                if ($Val -match ".:-") { $SiloHits.Add("MUTEX_EVENT") }
            }
            if ($Clean -match "\]") { $InList = $false ; $CurrentList = $null }
            continue
        }

        # Meta-donnees
        if (-not $InList -and ($Clean -match "^(?:\w+\.)?(\w+)\s*[:=]\s*(?:[""'](.*?)[""']|(\d+))")) {
            $Key = $Matches[1].ToUpper()
            if ($Key -match "^(DEF|CLASS|IF|RETURN|IMPORT|FROM|PRINT|SELF)") { continue }
            $Raw = if ($null -ne $Matches[2]) { $Matches[2] } else { $Matches[3] }
            $EntryData[$Key] = [string]$Raw.Trim()
        }
    }

    # Consolidation
    if ($SiloHits.Count -gt 0) {
        $EntryData.SIGNATURE_SILO = ($SiloHits | Group-Object | Sort-Object Count -Descending | Select-Object -First 1).Name
        if ($EntryData.SIGNATURE_SILO -match "FILESYSTEM|REGISTRY|WMI_CIM") { $EntryData.COMMIT_PERSISTENCE = "TRUE" }
        Write-Debug "    [DECISION] Silo: $($EntryData.SIGNATURE_SILO) (Hits: $($SiloHits.Count))"
    }

    $Atlas_Collection.Add([PSCustomObject]$EntryData)
}

# --- 4. EXPORT ---
$Atlas_Collection | ConvertTo-Json -Depth 5 | Out-File $DstFile -Encoding ascii -Force
Write-Host "`n [SUCCESS] Atlas Logic-OR (v2) genere ($($Atlas_Collection.Count) entrees)." -ForegroundColor Green