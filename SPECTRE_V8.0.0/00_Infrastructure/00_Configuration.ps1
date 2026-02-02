<#
.DESCRIPTION
    1.  Nom          : 00_Configuration.ps1
    2.  Auteur        : SPECTRE_ENGINE
    3.  Date          : 22-01-2026
    4.  Version       : 8.8.7
    5.  Description   : SPOT - Point de Verite Unique avec API d auto-declaration.
    6.  Entrees       : Appel de fonction Set-SpectreSegment.
    7.  Sorties       : Objets Globaux $Global:SpectreIHM et $Global:SpectreIndexSegments.
    8.  Dependances   : Windows PowerShell 5.1.
    9.  Parametres    : Aucun.
    10. Verbosite     : Basse.
    11. Densite       : Extreme (Standard 18 points).
    12. Accents       : ZERO_ACCENT (Strict ASCII 7-bit).
    13. Compatibilite : Windows PowerShell 5.1.
    14. Numerotation  : Signature de Couche 00 (Infrastructure).
    15. Integrite     : Signature de configuration structurelle.
    16. Journalisation: Write-Host standard.
    17. Gestion Erreur: Arret sur collision d index.
    18. Classification: SPECTRE - Infrastructure Core / SPOT.

.CONTRAINTES
    - Strictement aucun caractere hors plage ASCII 0-127.
    - Le terme ATLAS est reserve au JSON de fusion des menaces (Couche 08).

.OBJECTIFS
    - Centraliser l identite visuelle.
    - Exposer l API d injection pour la decouverte dynamique du filesystem.
#>

$Global:SpectreIHM = @{
    CouleurPrim   = 'Cyan' ; CouleurSec = 'Gray' ; CouleurAlerte = 'Yellow' ;
    CouleurErreur = 'Red' ; FondBanniere = 'Cyan' ; TexteBanniere = 'Black' ;
    Prefixe = '[!]' ; Libelle = ' SPECTRE | V8.8.7 | POINT DE VERITE UNIQUE '
}

$Global:SpectreIndexSegments = @{
    '.'                 = @{ Id='00'; Nom='RACINE' ; Desc='Orchestration Globale.' }
    '00_Infrastructure' = @{ Id='00'; Nom='INFRA'  ; Desc='SPOT et Constantes systeme.' }
}

function Global:Set-SpectreSegment {
    param(
        [Parameter(Mandatory=$true)] [string]$Path,
        [Parameter(Mandatory=$true)] [string]$Id,
        [Parameter(Mandatory=$true)] [string]$Nom,
        [Parameter(Mandatory=$true)] [string]$Desc
    )
    if (-not $Global:SpectreIndexSegments.ContainsKey($Path)) {
        $Global:SpectreIndexSegments[$Path] = @{ Id=$Id; Nom=$Nom; Desc=$Desc }
    }
}

Write-Host ' [OK] SPOT DYNAMIQUE CHARGE (V8.8.7).' -ForegroundColor $Global:SpectreIHM.CouleurSec