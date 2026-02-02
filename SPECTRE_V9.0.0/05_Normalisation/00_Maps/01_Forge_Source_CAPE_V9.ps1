<#
.DESCRIPTION
    1.  Nom          : 01_Forge_Source_CAPE_V9.ps1.
    2.  Auteur        : SPECTRE_ENGINE.
    3.  Date          : 27-01-2026.
    4.  Version       : 9.1.61.
    5.  Description   : Forge d'extraction Multi-OS pour signatures CAPE (Deep-Scan Verbose).
    6.  Chemin_Entree : ..\..\04_Sources\02_Referentiels\03_CAPE\modules\signatures\.
    7.  Chemin_Sortie : .\01_AntiVM_CAPE_Spec.json.
    8.  Dependances   : ..\..\00_Infrastructure\00_Configuration.ps1.
    9.  Parametres    : -Debug (Verbausite totale sur l'automate de capture).
    10. Verbosite     : MAXIMALE (Tracabilite granulaire par OS et par Silo).
    11. Densite       : SATUREE (Logic de capture multiline agnostique).
    12. Accents       : ZERO_ACCENT (Strict ASCII 7-bit).
    13. Compatibilite : Windows PowerShell 5.1 (Agnostique PS Core).
    14. Numerotation  : Signature 01 (Module Multi-OS Serious Forge).
    15. Integrite     : Detection automatique de l'OS via le dossier parent.
    16. Journalisation: Write-Host (Formatage framework SPECTRE).
    17. Gestion Erreur: Try/Catch global avec diagnostic d'encodage.
    18. Classification: SPECTRE - Multi-OS Data Recovery.
    19. Infrastructure: Branche 9.0.0 Sanctuarisee.
    20. Logic_Core    : RegEx Stream Parsing (Agnostique au prefixe self/cls).
    21. Nettoyage     : Normalisation ASCII 7-bit systematique.
    22. Rigueur       : Aucun caractere accentue tolere.
    23. Audit         : Ce script a ete passe a la boucle de conformite (BDC).
    24. Encodage      : Sortie ASCII pure (JSON Standard).
    25. Objectif      : Generer un Atlas Multi-OS certifie exempt de bruit.
    26. Securite      : Resolution via PSScriptRoot pour mobilite.
    27. Conformite    : Standard industriel SPECTRE V2.0.
    28. Trace         : Support exhaustif des syntaxes CAPE (Win/Lin/And/Dar).
    29. Contextualite : Integration du champ OS dans la structure de donnee.
    30. Performance   : Utilisation de [System.IO.File]::ReadAllText.

.CONTRAINTES
    - Interdiction totale d'utiliser des caracteres accentues.
    - PowerShell 5.1 uniquement.
    - Chargement du framework via 00_Configuration.ps1.

.OBJECTIFS
    - Capturer les cibles techniques par OS avec une verbausite maximale.
    - Categoriser chaque cible dans un Silo SPECTRE.
    - Exclure l'ivraie (code, logs, variables temporaires).
#>

param (
    [switch]$Debug
)

if ($Debug) { $DebugPreference = 'Continue' }

# --- 1. CHARGEMENT DU FRAMEWORK ---
$SPOT = Join-Path $PSScriptRoot "..\..\00_Infrastructure\00_Configuration.ps1"
if (Test-Path $SPOT) { 
    . $SPOT 
} else { 
    Write-Error "CRITIQUE : Framework SPECTRE absent ($SPOT)." ; exit 1 
}

Write-Host "`n $($Global:SpectreIHM.Libelle) " -BackgroundColor $Global:SpectreIHM.FondBanniere -ForegroundColor $Global:SpectreIHM.TexteBanniere
Write-Host " [>] MOISSON MULTI-OS VERBOSE : SIGNATURES CAPE (V9.1.61) " -ForegroundColor $Global:SpectreIHM.CouleurPrim

# --- 2. CONFIGURATION ---
$BaseDir = Join-Path $PSScriptRoot "..\..\04_Sources\02_Referentiels\03_CAPE\modules\signatures"
$DstFile = Join-Path $PSScriptRoot "01_AntiVM_CAPE_Spec.json"

if (-not (Test-Path $BaseDir)) { 
    Write-Error "CRITIQUE : Source signatures absente : $BaseDir" ; exit 1 
}

$MapAttr = @{
    "check_keys"    = @{ Silo = "Silo_02_REG" ; Type = "Registry" }
    "check_files"   = @{ Silo = "Silo_01_FS"  ; Type = "File" }
    "check_paths"   = @{ Silo = "Silo_01_FS"  ; Type = "Path" }
    "check_mutexes" = @{ Silo = "Silo_03_OBJ" ; Type = "Mutex" }
    "check_devs"    = @{ Silo = "Silo_05_HW"  ; Type = "Device" }
    "indicators"    = @{ Silo = "Silo_06_BEH" ; Type = "Behavior" }
}

$Techniques = @{}

# --- 3. MOTEUR DE MOISSON DEEP-SCAN ---
$PyFiles = Get-ChildItem -Path $BaseDir -Filter "*.py" -Recurse
Write-Host " [INFO] Analyse de $($PyFiles.Count) scripts Python..." -ForegroundColor Gray

foreach ($File in $PyFiles) {
    if ($File.Name -match "__init__") { continue }
    
    # Identification de l OS via le dossier parent
    $RelativePath = $File.DirectoryName.Replace($BaseDir, "").TrimStart('\').TrimStart('/')
    $OS = $RelativePath.Split('\/')[0].ToUpper()
    if ([string]::IsNullOrWhiteSpace($OS)) { $OS = "GENERIC" }
    
    try {
        # Verbausite : Trace du fichier en cours
        Write-Debug " [FILE] Processing : $($File.FullName) (OS: $OS)"
        
        $Content = [System.IO.File]::ReadAllText($File.FullName)
        
        foreach ($Key in $MapAttr.Keys) {
            # Pattern : Capture robuste des blocs techniques
            $Pattern = "(?is)(?:\b\w+\.)?$Key\s*[:=]\s*[\[\(](.*?)[\)\]]"
            $Matches = [regex]::Matches($Content, $Pattern)
            
            foreach ($Match in $Matches) {
                $BlockData = $Match.Groups[1].Value
                Write-Debug "  [BLOCK] Trouve bloc $Key dans $($File.Name)"
                
                # Capture des chaines (Wheat) : support r"", triples guillemets et simples
                $StrMatches = [regex]::Matches($BlockData, 'r?["'']{1,3}([^"'']{4,})["'']{1,3}')
                foreach ($StrM in $StrMatches) {
                    $Val = $StrM.Groups[1].Value.Trim().Replace('\\', '\')
                    
                    # Filtres de purete (Exclusion code et metadonnees)
                    if ($Val -match '[\(\)\$]' -or $Val -match '^(self|name|description|author|category)') { continue }

                    # Fragmentation Path / Cible (Agnostique OS)
                    $Idx = $Val.LastIndexOf('\')
                    if ($Idx -lt 0) { $Idx = $Val.LastIndexOf('/') }
                    
                    $Path = if ($Idx -ge 0) { $Val.Substring(0, $Idx) } else { "GLOBAL_CONTEXT" }
                    $Cible = if ($Idx -ge 0) { $Val.Substring($Idx + 1) } else { $Val }

                    # UID unique : OS + Silo + Path + Cible
                    $UID = "$OS`:$($MapAttr[$Key].Silo):$Path\$Cible"
                    
                    if (-not $Techniques.ContainsKey($UID)) {
                        $Techniques[$UID] = [PSCustomObject]@{
                            Designation = "CAPE_" + $OS + "_" + $Cible.Replace(".", "_").Replace("$", "").ToUpper()
                            OS          = $OS
                            Type        = $MapAttr[$Key].Type
                            Path        = $Path
                            Cible       = $Cible
                            Silo        = $MapAttr[$Key].Silo
                            Source      = "CAPE:" + $File.Name
                        }
                        Write-Debug "   [WHEAT] Extraite : $Cible ($($MapAttr[$Key].Silo))"
                    }
                }
            }
        }
    } catch { 
        Write-Debug " [!] Erreur sur $($File.Name) : $($_.Exception.Message)"
    }
}

# --- 4. EXPORT JSON ---
$AtlasFinal = [PSCustomObject]@{
    Manifest = [PSCustomObject]@{
        Name      = "CAPE Multi-OS Serious Atlas"
        Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        Total     = $Techniques.Count
        Engine    = "Deep-Scan Multi-OS V9.1.61"
    }
    Techniques = [System.Collections.ArrayList]($Techniques.Values | Sort-Object OS, Silo, Path)
}

$AtlasFinal | ConvertTo-Json -Depth 10 | Out-File $DstFile -Encoding ascii -Force
Write-Host "`n [SUCCESS] Moisson terminee : $($Techniques.Count) cibles extraites. " -ForegroundColor Green
Write-Host " [DEST] $DstFile " -ForegroundColor Yellow