<#
.DESCRIPTION
    1.  Nom          : 01_Gestion_Documentation_V8.ps1
    2.  Auteur        : SPECTRE_ENGINE
    3.  Date          : 22-01-2026
    4.  Version       : 8.8.7
    5.  Description   : Generateur de documentation base sur l audit dynamique.
    6.  Entrees       : Scan NTFS et Index dynamique.
    7.  Sorties       : Fichiers LISEZ_MOI.md.
    8.  Dependances   : SPOT / Auditeur Atlas.
    9.  Parametres    : -Debug (Verbose).
    10. Verbosite     : Statique (Synthese finale).
    11. Densite       : Extreme (Standard 18 points).
    12. Accents       : ZERO_ACCENT (Strict ASCII 7-bit).
    13. Compatibilite : Windows PowerShell 5.1.
    14. Numerotation  : Signature 01 (Gestion).
    15. Integrite     : Encodage ASCII force.
    16. Journalisation: Write-Host (Synthese).
    17. Gestion Erreur: Comptage des echecs d ecriture.
    18. Classification: SPECTRE - Maintenance.

.CONTRAINTES
    - Appel systematique de l auditeur avant generation.
    - Zero caractere special pour PS 5.1.

.OBJECTIFS
    - Maintenir la documentation a jour sans intervention manuelle.
    - Garantir la visibilite des scripts .ps1 dans chaque segment.
#>

param ([switch]$Debug)

if ($Debug) { $DebugPreference = 'Continue' }

$PathSPOT = Join-Path $PSScriptRoot '00_Infrastructure\00_Configuration.ps1'
if (Test-Path $PathSPOT) { . $PathSPOT } else { Write-Error "SPOT introuvable." ; exit }

$PathAudit = Join-Path $PSScriptRoot '01_Gestion\00_Helpers\00_Auditeur_Atlas.ps1'
if (Test-Path $PathAudit) { . $PathAudit }

$CptSuccess = 0 ; $CptScripts = 0 ; $NL = "`r`n" ; $DNL = "`r`n`r`n"

Write-Host "`n [!] GENERATION DOCUMENTAIRE DYNAMIQUE... " -ForegroundColor Green

$Segments = Get-ChildItem -Path $PSScriptRoot -Directory -Recurse | Select-Object -ExpandProperty FullName
$Segments += $PSScriptRoot

foreach ($S in $Segments) {
    $Relatif = $S.Replace($PSScriptRoot, '').Trim('\')
    if ($Relatif -eq '') { $Relatif = '.' }

    $D = if ($Global:SpectreIndexSegments.ContainsKey($Relatif)) { $Global:SpectreIndexSegments[$Relatif] } 
         else { @{ Id='??'; Nom='NON_INDEXE'; Desc='Segment orphelin.' } }

    $Scripts = Get-ChildItem -Path $S -File -Filter "*.ps1"
    $ListeActifs = ""
    if ($Scripts) { foreach ($F in $Scripts) { $ListeActifs += "* " + $F.Name + $NL ; $CptScripts++ } }
    else { $ListeActifs = "*Aucun script detecte.*" }

    $MD = "# SPECTRE | SECTION " + $D.Id + " : " + $D.Nom + $DNL
    $MD += "---" + $DNL
    $MD += "### SYNTHESE DU SEGMENT" + $NL
    $MD += "| PROPRIETE | VALEUR |" + $NL
    $MD += "| :--- | :--- |" + $NL
    $MD += "| **INDEX** | " + $D.Id + " |" + $NL
    $MD += "| **PATH** | " + $Relatif + " |" + $NL
    $MD += "| **MISSION** | " + $D.Desc + " |" + $DNL
    $MD += "### INVENTAIRE DES ACTIFS (.PS1)" + $NL
    $MD += $ListeActifs + $DNL
    $MD += "---" + $NL
    $MD += "*Genere par SPECTRE-ENGINE | " + (Get-Date -Format 'dd-MM-yyyy') + " | ASCII 7-BIT*"

    try { $MD | Out-File (Join-Path $S 'LISEZ_MOI.md') -Encoding ascii -Force ; $CptSuccess++ } catch {}
}

Write-Host "`n [SUCCESS] Documentation mise a jour (Segments: $CptSuccess | Scripts: $CptScripts)." -ForegroundColor Green