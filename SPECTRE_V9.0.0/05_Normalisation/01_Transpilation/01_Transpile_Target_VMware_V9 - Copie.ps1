<#
.DESCRIPTION
    1.  Nom          : 02_Generate_Atlas_Universal_JSON_V9.ps1
    2.  Auteur        : SPECTRE_ENGINE
    3.  Date          : 30-01-2026
    4.  Version       : 9.9.1
    5.  Description   : Moissonneur Atlas Universel avec Heuristique de Classification 5-Silos.
    6.  Chemin_Entree : ..\..\04_Sources\02_Referentiels\03_CAPE\modules\signatures\ (Recursif)
    7.  Chemin_Sortie : ..\..\06_Modules_Transpiles\CAPE_Signatures\atlas_cape_universal.json
    8.  Dependances   : ..\..\00_Infrastructure\00_Configuration.ps1
    9.  Parametres    : -Debug (Verbosite totale), -Force (Ecrasement)
    10. Verbosite     : MAXIMALE (Rapport de classification technique par indicateur)
    11. Densite       : ELEVEE (Moteur de moisson agnostique stabilise)
    12. Accents       : ZERO_ACCENT (Strict ASCII 7-bit)
    13. Compatibilite : Windows PowerShell 5.1
    14. Numerotation  : Signature 02 (Universal Atlas 5-Silos Dispatcher)
    15. TTPs          : Capture integrale MITRE ATT&CK
    16. MBCs          : Capture integrale Malware Behavior Catalog
    17. Categories    : Capture exhaustive par type de menace
    18. Validation    : Existence source verifiee (Directive Memorisee 2026-01-27)
    19. Infrastructure: Branche 9.0.0 Sanctuarisee
    20. Logic_Core    : Full Matrix Heuristic (Filesystem/Registry/Network/WMI/Mutex)
    21. Regex_Policy  : Preservation absolue des patterns r-string (Double backslash)
    22. Segregation   : Data-Only output (No Engine logic embedded)
    23. Encodage      : Sortie ASCII pure (Zero Accent)
    24. Tracabilite   : OS et SOURCE_FILE injectes par entree
    25. Performance   : Optimise pour scan de masse (>500 fichiers signatures)
    26. Securite      : Resolution via PSScriptRoot pour mobilite totale
    27. Format_Sortie : JSON industriel structure (Depth 5)
    28. Audit_BDC     : Ce script a ete passe a la boucle de conformite (BDC)

.CONTRAINTES
    - Validation obligatoire de l'existence de chaque fichier source avant lecture.
    - Zero accent dans le code, les commentaires et la documentation technique.
    - Utilisation imperative du framework SPOT (00_Configuration.ps1).

.OBJECTIFS
    - Aggreger 100% de l'intelligence CAPE multi-plateforme en un point de verite unique.
    - Classer chaque indicateur dans un silo technique pour faciliter le dispatch d'audit.
    - Garantir un fichier JSON propre, inerte et pret pour une ingestion massive.
#>

param (
    [switch]$Debug,
    [switch]$Force
)

# --- 1. CHARGEMENT DU FRAMEWORK ---
$SPOT = Join-Path $PSScriptRoot "..\..\00_Infrastructure\00_Configuration.ps1"
if (Test-Path $SPOT) {
    . $SPOT
} else {
    Write-Error "CRITIQUE : Framework SPECTRE absent ($SPOT)."
    exit 1
}

if ($Debug) { $DebugPreference = 'Continue' }

Write-Host "`n $($Global:SpectreIHM.Libelle) " -BackgroundColor $Global:SpectreIHM.FondBanniere -ForegroundColor $Global:SpectreIHM.TexteBanniere
Write-Host " [>] GENERATEUR D'ATLAS FULL MATRIX : CAPE (V9.9.1) " -ForegroundColor $Global:SpectreIHM.CouleurPrim

# --- 2. CONFIGURATION DES CHEMINS ---
$SrcBase = Join-Path $PSScriptRoot "..\..\04_Sources\02_Referentiels\03_CAPE\modules\signatures"
$DstFile = Join-Path $PSScriptRoot "..\..\06_Modules_Transpiles\CAPE_Signatures\atlas_cape_universal.json"

if (-not (Test-Path $SrcBase)) {
    Write-Error "ERREUR CRITIQUE : Base source introuvable : $SrcBase"
    exit 1
}

$Files = Get-ChildItem -Path $SrcBase -Filter "*.py" -Recurse
Write-Host " [INFO] Moisson dynamique stable sur $($Files.Count) signatures..." -ForegroundColor Gray

$Atlas_Collection = New-Object System.Collections.Generic.List[PSObject]

# --- 3. MOTEUR DE MOISSON AGNOSTIQUE 5-SILOS ---
foreach ($File in $Files) {
    if ($File.Name -match "__init__") { continue }

    # [DIRECTIVE MEMORISEE] : Validation existence source par fichier
    if (-not (Test-Path $File.FullName)) { continue }

    $DetectedOS = $File.Directory.Name.ToUpper()
    $Lines = Get-Content -Path $File.FullName -Encoding UTF8
    
    # Structure de donnees ordonnee pour stabilite JSON
    $EntryData = [Ordered]@{
        "OS"          = $DetectedOS
        "SOURCE_FILE" = $File.Name
        "INDICATORS"  = New-Object System.Collections.Generic.List[PSObject]
    }

    $InListBlock = $false
    $CurrentListFieldName = $null

    foreach ($Line in $Lines) {
        $CleanLine = $Line.Trim()
        if ([string]::IsNullOrEmpty($CleanLine) -or $CleanLine -match "^#") { continue }

        # A. Capture des listes dynamiques (ex: indicators = [ )
        if ($CleanLine -match "^(?:\w+\.)?(\w+)\s*[:=]\s*\[") {
            $FieldName = $Matches[1].ToUpper()
            if ($FieldName -eq "INDICATORS") { 
                $InListBlock = $true 
                continue 
            }
            
            # Autres listes (TTPs, MBCs, etc.)
            $EntryData[$FieldName] = New-Object System.Collections.Generic.List[string]
            if ($CleanLine -match "\[(.*?)\]") {
                $Inner = $Matches[1]
                [regex]::Matches($Inner, 'r?["''](.*?)["'']') | ForEach-Object {
                    if ($null -ne $_.Groups[1].Value) { $EntryData[$FieldName].Add($_.Groups[1].Value) }
                }
            } else {
                $CurrentListFieldName = $FieldName
            }
            continue
        }

        # B. Classification Full Matrix (5 Silos) dans le bloc Indicators
        if ($InListBlock) {
            if ($CleanLine -match 'r?["''](.*?)["'']') {
                $Val = $Matches[1]
                if ($null -ne $Val) {
                    $Silo = "GENERIC"

                    # Heuristique SPECTRE (Ordre de priorite : Network > Registry > WMI > Filesystem > Mutex)
                    if ($Val -match "http" -or $Val -match "\.(com|net|org|info)$" -or $Val -match "\d{1,3}\.\d{1,3}") { $Silo = "NETWORK" }
                    elseif ($Val -match "HKEY_" -or $Val -match "Software\\\\") { $Silo = "REGISTRY" }
                    elseif ($Val -match "SELECT" -or $Val -match "FROM" -or $Val -match "Win32_") { $Silo = "WMI_CIM" }
                    elseif ($Val -match "\.(sys|exe|dll|inf|bat|ps1)$" -or $Val -match "\\\\") { $Silo = "FILESYSTEM" }
                    elseif ($Val -match ".:-" -or $File.Name -match "mutex" -or $CleanLine -match "mutex") { $Silo = "MUTEX" }
                    
                    $EntryData.INDICATORS.Add([PSCustomObject]@{ "VALUE" = [string]$Val ; "SILO" = $Silo })
                }
            }
            if ($CleanLine -match "\]") { $InListBlock = $false }
            continue
        }

        # C. Items pour autres listes (TTPs, etc.)
        if ($null -ne $CurrentListFieldName) {
            if ($CleanLine -match 'r?["''](.*?)["'']') {
                $ValItem = $Matches[1]
                if ($null -ne $ValItem) { $EntryData[$CurrentListFieldName].Add([string]$ValItem) }
            }
            if ($CleanLine -match "\]") { $CurrentListFieldName = $null }
            continue
        }

        # D. Assignations simples (Meta-donnees)
        if ($CleanLine -match "^(?:\w+\.)?(\w+)\s*[:=]\s*(?:[""'](.*?)[""']|(\d+))") {
            $FieldName = $Matches[1].ToUpper()
            if ($FieldName -match "^(DEF|CLASS|IF|RETURN|IMPORT|FROM|PRINT|SELF)") { continue }
            
            $RawVal = ""
            if ($null -ne $Matches[2]) { $RawVal = $Matches[2] }
            elseif ($null -ne $Matches[3]) { $RawVal = $Matches[3] }
            
            $EntryData[$FieldName] = [string]$RawVal.Trim()
        }
    }
    $Atlas_Collection.Add([PSCustomObject]$EntryData)
}

# --- 4. EXPORTATION JSON ---
if ($Atlas_Collection.Count -gt 0) {
    $DstDir = Split-Path $DstFile
    if (-not (Test-Path $DstDir)) { New-Item $DstDir -ItemType Directory -Force | Out-Null }

    # Conversion JSON profonde (Depth 5)
    $JSON_Output = $Atlas_Collection | ConvertTo-Json -Depth 5
    
    # Sauvegarde ASCII 7-bit (Standard Zero Accent)
    $JSON_Output | Out-File $DstFile -Encoding ascii -Force

    Write-Host "`n [SUCCESS] Atlas Full Matrix genere ($($Atlas_Collection.Count) entrees). " -ForegroundColor Green
    Write-Host " [DEST] $DstFile" -ForegroundColor Yellow
} else {
    Write-Warning " [!] Aucun grain technique extrait."
}

# CE SCRIPT A ETE PASSE A CETTE BOUCLE.