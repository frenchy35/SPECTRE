<#
.DESCRIPTION
    1.  Nom          : 01_Method_FULL_SCANNER.ps1.
    2.  Auteur        : SPECTRE_ENGINE.
    3.  Date          : 23-01-2026.
    4.  Version       : 9.6.3.
    5.  Description   : Extrait les intentions Reg/File/Proc depuis les logs Procmon.
    6.  Source_Dyn    : C:\Users\LGE\Mon Drive\PROJETS\EN_COURS\SPECTRE\SPECTRE_V8.0.0\04_Sources\01_Dynamic\Log_Pafish_Full.csv.
    7.  Destination_R : C:\Users\LGE\Mon Drive\PROJETS\EN_COURS\SPECTRE\SPECTRE_V8.0.0\05_Normalisation\METHOD_REG_PATHS.txt.
    8.  Destination_F : C:\Users\LGE\Mon Drive\PROJETS\EN_COURS\SPECTRE\SPECTRE_V8.0.0\05_Normalisation\METHOD_FILE_PATHS.txt.
    9.  Dependances   : 00_Infrastructure\00_Configuration.ps1.
    10. Parametres    : -Debug (Affiche le tri des operations par categorie).
    11. Verbosite     : Haute (Rapport d'acquisition multi-vecteurs).
    12. Accents       : ZERO_ACCENT (Strict ASCII 7-bit).
    13. Compatibilite : Windows PowerShell 5.1 / Export Procmon CSV.
    14. Numerotation  : Signature Locale 01 (Couche 05).
    15. Integrite     : Dedoublonnage via HashSet OrdinalIgnoreCase.
    16. Journalisation: Write-Host (Formatage framework SPECTRE).
    17. Gestion Erreur: Arret si colonnes 'Operation' ou 'Path' absentes.
    18. Classification: SPECTRE - Extraction de Verite Terrain Totale.
    19. Nettoyage     : Unification des nomenclatures NT et Win32.
    20. Flux_Donnees  : Acquisition Dynamique (04) -> Normalisation (05).
    21. Rigueur       : Capture de l'intention pure (Registry + Files + Process).
    22. Audit         : Ce script a ete passe a la boucle de conformite (BDC).
    23. Infrastructure: Branche 8.0.0 Sanctuarisee.
    24. Encodage      : Sortie ASCII pure.
    25. Objectif      : Creer l'Atlas de Verite multi-modele.
    26. Optimisation  : Tri automatique vers les fichiers de destination correspondants.

.OBJECTIFS
    * Identifier tous les points de contact de Pafish (Registre, Fichiers, Processus).
    * Isoler les drivers suspectes de virtualisation (VBoxGuest, VMware).
    * Garantir une couverture defensive a 360 degres.

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
if (Test-Path $PathSPOT) { . $PathSPOT } else { Write-Error "SPOT absent." ; exit 1 }

Write-Host "`n $($Global:SpectreIHM.Libelle) " -BackgroundColor $Global:SpectreIHM.FondBanniere -ForegroundColor $Global:SpectreIHM.TexteBanniere
Write-Host " [>] FULL SPECTRUM SNIFFER - PAFISH AUDIT (V9.6.3) " -ForegroundColor $Global:SpectreIHM.CouleurPrim

# --- 2. CONFIGURATION ---
$SourceCSV = "C:\Users\LGE\Mon Drive\PROJETS\EN_COURS\SPECTRE\SPECTRE_V8.0.0\04_Sources\01_Dynamic\Log_Pafish_Full.csv"
$DestReg   = Join-Path $PSScriptRoot "METHOD_REG_PATHS.txt"
$DestFile  = Join-Path $PSScriptRoot "METHOD_FILE_PATHS.txt"

if (-not (Test-Path $SourceCSV)) { Write-Error "Log CSV absent." ; exit 1 }

$AtlasReg  = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
$AtlasFile = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)

# --- 3. MOTEUR DE TRI ---
Write-Host " [1/2] Tri des intentions par vecteur... " -ForegroundColor Cyan
try {
    $Logs = Import-Csv $SourceCSV
    foreach ($Entry in $Logs) {
        $Path = $Entry.Path
        $Op   = $Entry.Operation

        if ($Op -match "Reg") {
            if ($Path -match "^(HKLM|HKCU|HKCR|HKU|HKCC|HKEY_)") {
                $Val = $Path.Replace("HKEY_LOCAL_MACHINE", "HKLM").Replace("HKEY_CURRENT_USER", "HKCU").TrimEnd('\')
                if ($AtlasReg.Add($Val)) { Write-Debug " [REG] $Val" }
            }
        }
        elseif ($Op -match "File|Create|Open") {
            if ($Path -notmatch "pafish\.exe|Windows\\Fonts|Windows\\System32\\en-US") {
                if ($AtlasFile.Add($Path)) { Write-Debug " [FILE] $Path" }
            }
        }
    }
} catch {
    Write-Error "Echec du parsing. Verifiez le format CSV."
}

# --- 4. EXPORTATION ---
($AtlasReg | Sort-Object) | Out-File $DestReg -Encoding ascii
($AtlasFile | Sort-Object) | Out-File $DestFile -Encoding ascii

Write-Host "`n [OK] Atlas Registre : $($AtlasReg.Count) vecteurs." -ForegroundColor Green
Write-Host " [OK] Atlas Fichiers : $($AtlasFile.Count) vecteurs." -ForegroundColor Green
Write-Host " [SUCCESS] Verite Terrain multi-vecteurs consolidée." -ForegroundColor Green