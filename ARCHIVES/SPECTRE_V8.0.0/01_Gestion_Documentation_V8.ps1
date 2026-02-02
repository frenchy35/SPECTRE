<#
.DESCRIPTION
    1.  Nom          : 01_Gestion_Documentation_V8.ps1
    2.  Auteur        : SPECTRE_ENGINE
    3.  Date          : 22-01-2026
    4.  Version       : 8.4.0
    5.  Description   : Generateur de documentation haute densite. Utilise le SPOT pour construire une tracabilite contextuelle par segment.
    9.  Parametres    : -Debug (Affiche les etapes de concatenation).
    12. Accents       : ZERO_ACCENT.
    14. Numerotation  : 01_.

.OBJECTIFS
    - Maintenir une documentation technique a jour sans intervention manuelle.
    - Exposer visuellement le pipeline de donnees (In/Out).
#>

param (
    [switch]$Debug
)

# --- CHARGEMENT DU SPOT ---
$PathSPOT = Join-Path $PSScriptRoot '00_Infrastructure\00_Configuration.ps1'
if (Test-Path $PathSPOT) { . $PathSPOT } else { Write-Error "SPOT Introuvable" ; exit }

if ($Debug) { $DebugPreference = 'Continue' }
$DateStr = Get-Date -Format 'dd-MM-yyyy'
$NL = "`r`n" ; $DNL = "`r`n`r`n"

Write-Host "`n $($Global:SpectreIHM.Libelle) " -BackgroundColor $Global:SpectreIHM.FondBanniere -ForegroundColor $Global:SpectreIHM.TexteBanniere
Write-Host " [!] GENERATION DOCUMENTAIRE CONTEXTUELLE " -ForegroundColor $Global:SpectreIHM.CouleurPrim

# --- PARCOURS DE L ATLAS ---
$Items = Get-ChildItem -Path $PSScriptRoot -Directory -Recurse | Select-Object -ExpandProperty FullName
$Items += $PSScriptRoot

foreach ($P in $Items) {
    $Rel = $P.Replace($PSScriptRoot, '').Trim('\')
    if ($Rel -eq '') { $Rel = '.' }
    
    Write-Debug (" [DEBUG] Traitement du segment : " + $Rel)

    if ($Global:SpectreAtlas.ContainsKey($Rel)) {
        $D = $Global:SpectreAtlas[$Rel]
    } else {
        $D = @{ Nom='AUXILIAIRE'; Desc='Support technique'; InQui='Amont'; InOu='Flux'; OutQui='Aval'; OutOu='Flux'; Quoi='Data' }
    }

    # CONSTRUCTION HAUTE DENSITE (ASCII PUR)
    $MD = '# SECTION SPECTRE : ' + $D.Nom + $DNL
    $MD += '========================================================================' + $DNL
    $MD += '### MISSION DU SEGMENT' + $NL
    $MD += '**' + $D.Desc + '**' + $DNL
    $MD += '---' + $DNL
    $MD += '### CARTOGRAPHIE DES FLUX (I/O)' + $DNL
    $MD += '| DIRECTION | ENTITE (QUI) | LOCALISATION (OU) | MATIERE (QUOI) |' + $NL
    $MD += '| :--- | :--- | :--- | :--- |' + $NL
    $MD += '| **[ENTREE]** | ' + $D.InQui + ' | `' + $D.InOu + '` | **' + $D.Quoi + '** |' + $NL
    $MD += '| **[SORTIE]** | ' + $D.OutQui + ' | `' + $D.OutOu + '` | **' + $D.Quoi + '** |' + $DNL
    $MD += '---' + $DNL
    $MD += '### DIAGRAMME DE CIRCULATION' + $NL
    $MD += '```text' + $NL
    $MD += '      SOURCE : [ ' + $D.InQui + ' ]' + $NL
    $MD += '                  |' + $NL
    $MD += '                  v' + $NL
    $MD += '      FLUX   : ( ' + $D.Quoi + ' )' + $NL
    $MD += '                  |' + $NL
    $MD += '                  v' + $NL
    $MD += '      SEGMENT: { ' + $Rel + ' }' + $NL
    $MD += '                  |' + $NL
    $MD += '                  v' + $NL
    $MD += '      CIBLE  : [ ' + $D.OutQui + ' ]' + $NL
    $MD += '```' + $DNL
    $MD += '---' + $DNL
    $MD += '### STANDARDS OPERATIONNELS' + $NL
    $MD += '1. **audit** : Validation de l integrite.' + $NL
    $MD += '2. **commit** : Execution de la transformation.' + $NL
    $MD += '3. **rollback** : Restauration securisee.' + $DNL
    $MD += '========================================================================' + $DNL
    $MD += '*Genere le ' + $DateStr + ' | SPECTRE BRANCH 8.0.0 | Statut : CONFORME*'

    $Dest = Join-Path $P 'LISEZ_MOI.md'
    $MD | Out-File $Dest -Encoding ascii -Force
    Write-Debug (" [DEBUG] Fichier cree : " + $Dest)
}

Write-Host "`n [SUCCESS] Tracabilite documentaire etablie." -ForegroundColor $Global:SpectreIHM.CouleurPrim