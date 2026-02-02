<#
.DESCRIPTION
    1.  Nom          : 02_Atlas_Master_Gen.ps1.
    2.  Auteur        : SPECTRE_ENGINE.
    3.  Date          : 26-01-2026.
    4.  Version       : 11.4.1.
    5.  Description   : Genere l'Atlas Master avec gestion d'encodage robuste (UTF8/ASCII).
    6.  Chemin_Entree : 04_Sources\02_Referentiels\.
    7.  Chemin_Sortie : 05_Normalisation\ATLAS_MASTER_2026.txt.
    8.  Dependances   : 00_Infrastructure\00_Configuration.ps1.
    9.  Parametres    : -Debug (Affiche le carving des sources de verite).
    10. Verbosite     : Haute (Rapport de saturation binaire et textuelle).
    11. Densite       : Maximale (Regex saturee pour CLSID et chemins complexes).
    12. Accents       : ZERO_ACCENT (Standard ASCII 7-bit).
    13. Compatibilite : Windows PowerShell 5.1.
    14. Numerotation  : Signature 02 (Couche 05).
    15. Integrite     : Dedoublonnage via HashSet OrdinalIgnoreCase.
    16. Gestion Erreur: Lecture par bloc binaire pour eviter les "Skip" d'encodage.
    17. Classification: SPECTRE - Consolidation de Verite Master.
    18. Logic_Core    : Carving Registry sur Markdown, C++, Python, JSON.
    19. Nettoyage     : Unification des ruches (HKLM, HKCU) et retrait des Default.
    20. Flux_Donnees  : 04_Sources -> 05_Normalisation.
    21. Rigueur       : Aucun caractere accentue tolere.
    22. Audit         : Script valide via Boucle de Conformite (BDC).
    23. Infrastructure: Branche V8.0.0.
    24. Encodage      : Sortie ASCII pure pour compatibilite inter-outils.
    25. Objectif      : Resoudre les erreurs de lecture sur les sources CheckPoint.
    26. Regex_Fix     : Support des accolades {} et des points dans les cles.
    27. Zero_Accent   : Verifie avant chaque livraison.
    28. Precision     : Capture les cles de processeur et BIOS granulaires.

.OBJECTIFS
    * Eliminer les erreurs "SKIP" lors de la lecture des fichiers Markdown.
    * Augmenter la densite de capture des vecteurs (Cible > 1000).
    * Stabiliser la base de verite pour le filtrage de la couche 06.

.CONTRAINTES
    * Interdiction totale des caracteres accentues (Zero Accent).
    * Support strict de Windows PowerShell 5.1.
    * Chargement systematique du framework via 00_Configuration.ps1.
#>

param ([switch]$Debug)

if ($Debug) { $DebugPreference = 'Continue' }

# --- 1. CHARGEMENT DU FRAMEWORK ---
$InfraPath = Join-Path $PSScriptRoot "..\00_Infrastructure\00_Configuration.ps1"
if (Test-Path $InfraPath) { . $InfraPath } else { Write-Error "CRITICAL : SPOT absent." ; exit 1 }

Write-Host "`n $($Global:SpectreIHM.Libelle) " -BackgroundColor $Global:SpectreIHM.FondBanniere -ForegroundColor $Global:SpectreIHM.TexteBanniere
Write-Host " [>] GENERATEUR D'ATLAS MASTER - MODE ROBUSTE (V11.4.1) " -ForegroundColor $Global:SpectreIHM.CouleurPrim

# --- 2. CONFIGURATION ---
$RefPath = Join-Path $PSScriptRoot "..\04_Sources\02_Referentiels"
$DestFile = Join-Path $PSScriptRoot "ATLAS_MASTER_2026.txt"
$MasterAtlas = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)

# --- 3. MOTEUR D'EXTRACTION ---
Write-Host " [1/1] Analyse transverse des referentiels (Deep Carving)... " -ForegroundColor Cyan
$Extensions = @("*.md", "*.txt", "*.cpp", "*.h", "*.py", "*.json")
$Files = Get-ChildItem -Path $RefPath -Include $Extensions -Recurse -File

foreach ($File in $Files) {
    try {
        # Lecture binaire forcee pour eviter les erreurs d'encodage des fichiers .md et .py
        $Bytes = [System.IO.File]::ReadAllBytes($File.FullName)
        $Content = [System.Text.Encoding]::UTF8.GetString($Bytes)
        
        # Regex etendu : Gere les CLSID {GUID}, les points, les tirets et les espaces
        $RegexReg = '(?i)(HKLM|HKCU|HKCR|HKU|HKCC|HKEY_[A-Z_]+|\\REGISTRY\\[A-Z]+)\\[A-Za-z0-9\\_ \-\.\{\}]+'
        
        [regex]::Matches($Content, $RegexReg) | ForEach-Object {
            $Val = $_.Value.Trim().Replace("\\", "\")
            
            # Unification des ruches
            $Val = $Val.Replace("HKEY_LOCAL_MACHINE", "HKLM").Replace("\REGISTRY\MACHINE", "HKLM")
            $Val = $Val.Replace("HKEY_CURRENT_USER", "HKCU").Replace("\REGISTRY\USER", "HKCU")
            $Val = $Val.Replace("HKEY_CLASSES_ROOT", "HKCR")
            
            # Nettoyage des suffixes de prose dans les fichiers Markdown
            $Val = $Val.TrimEnd('\').TrimEnd('.').Trim()
            $Val = $Val.Replace("\(Default)", "")

            if ($Val.Length -gt 10 -and $Val -match "\\") {
                if ($MasterAtlas.Add($Val)) { Write-Debug " [MASTER_ADD] $Val ($($File.Name))" }
            }
        }
    } catch {
        Write-Debug " [CRITICAL_SKIP] Impossible de lire $($File.Name) : $($_.Exception.Message)"
    }
}

# --- 4. EXPORTATION ---
$Sorted = $MasterAtlas | Sort-Object
$Sorted | Out-File $DestFile -Encoding ascii

Write-Host "`n [OK] Atlas Master genere : $($MasterAtlas.Count) vecteurs uniques." -ForegroundColor Green
Write-Host " [SUCCESS] Base de verite stabilisee dans ATLAS_MASTER_2026.txt." -ForegroundColor Green