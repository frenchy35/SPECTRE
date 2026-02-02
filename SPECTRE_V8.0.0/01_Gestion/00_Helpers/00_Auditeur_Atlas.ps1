<#
.DESCRIPTION
    1.  Nom          : 00_Auditeur_Atlas.ps1
    2.  Auteur        : SPECTRE_ENGINE
    3.  Date          : 22-01-2026
    4.  Version       : 8.8.7
    5.  Description   : Scanne le NTFS et declare dynamiquement les segments au SPOT.
    6.  Entrees       : Structure de dossiers physique.
    7.  Sorties       : Mise a jour de $Global:SpectreIndexSegments.
    8.  Dependances   : Windows PowerShell 5.1 / SPOT.
    9.  Parametres    : -Debug (Traces du scan).
    10. Verbosite     : Haute.
    11. Densite       : Extreme (Standard 18 points).
    12. Accents       : ZERO_ACCENT (Strict ASCII 7-bit).
    13. Compatibilite : Windows PowerShell 5.1.
    14. Numerotation  : Signature 00 (Helpers).
    15. Integrite     : Validation du pattern de nommage [0-9][0-9]_.
    16. Journalisation: Write-Host / Write-Debug.
    17. Gestion Erreur: Skip des dossiers non conformes a la nomenclature.
    18. Classification: SPECTRE - Infrastructure Support.

.CONTRAINTES
    - Doit etre execute apres le chargement du SPOT.
    - Respecte strictement le format de nommage numerote.

.OBJECTIFS
    - Synchroniser la realite physique du disque avec l Index logique.
    - Automatiser la decouverte des nouveaux segments.
#>

param ([switch]$Debug)

if ($Debug) { $DebugPreference = 'Continue' }

$RacinePath = (Get-Item $PSScriptRoot).Parent.Parent.FullName
Write-Host " [!] AUDIT DYNAMIQUE : Synchronisation NTFS -> SPOT..." -ForegroundColor Cyan

$Dossiers = Get-ChildItem -Path $RacinePath -Directory -Recurse | Where-Object { $_.Name -match "^[0-9][0-9]_" }

foreach ($D in $Dossiers) {
    $Rel = $D.FullName.Replace($RacinePath, '').Trim('\')
    $Parts = $D.Name.Split('_', 2)
    $Idx = $Parts[0]
    $Label = if ($Parts.Count -gt 1) { $Parts[1] } else { "SANS_NOM" }

    Set-SpectreSegment -Path $Rel -Id $Idx -Nom ($Label.ToUpper()) -Desc "Segment auto-detecte par l auditeur dynamique."
    Write-Debug (" [DEBUG] Segment indexe : " + $Rel + " [ID:" + $Idx + "]")
}

Write-Host (" [OK] " + $Global:SpectreIndexSegments.Count + " segments synchronises.") -ForegroundColor Gray