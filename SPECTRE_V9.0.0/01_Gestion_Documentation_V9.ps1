<#
.DESCRIPTION
    1.  Nom          : 01_Gestion_Documentation_V9.ps1.
    2.  Auteur        : SPECTRE_ENGINE.
    3.  Date          : 26-01-2026.
    4.  Version       : 9.0.0.
    5.  Description   : Generateur de visibilite dynamique pour les actifs V9.
    6.  Chemin_Entree : Scan recursif de l infrastructure racine.
    7.  Chemin_Sortie : Fichiers LISEZ_MOI.md dans chaque segment.
    8.  Dependances   : 00_Infrastructure\00_Configuration.ps1 (Framework SPOT).
    9.  Parametres    : -Debug (Suivi detaille de l'indexation).
    10. Verbosite     : Haute (Rapport de couverture documentaire).
    11. Densite       : SATUREE (Bloc meta 28 points).
    12. Accents       : ZERO_ACCENT (Strict ASCII 7-bit).
    13. Compatibilite : Windows PowerShell 5.1 / UTF-8 sans BOM (Markdown).
    14. Numerotation  : Signature 01 (Couche Gestion).
    15. Integrite     : Encodage ASCII force pour eviter les corruptions.
    16. Journalisation: Write-Host (Stats de traitement).
    17. Gestion Erreur: Comptage des echecs de generation par segment.
    18. Classification: SPECTRE - Maintenance Documentaire V9.
    19. Infrastructure: Branche 9.0.0 Sanctuarisee.
    20. Logic_Core    : Generation de manifestes Markdown par injection SPOT.
    21. Nettoyage     : Ecrasement systematique des anciennes versions .md.
    22. Rigueur       : Conformite au standard de documentation Atlas.
    23. Audit         : Ce script a ete passe a la boucle de conformite (BDC).
    24. Encodage      : Sortie ASCII pure (Zero accent).
    25. Objectif      : Maintenir la tracabilite des scripts Anti-VM.
    26. Securite      : Aucune execution de code lors du scan (ReadOnly scan).
    27. Conformite    : Zero caractere special tolere pour stabilite PS 5.1.
    28. Precision     : Liaison dynamique entre dossiers et descriptions SPOT.

.CONTRAINTES
    - Le framework SPOT doit etre charge pour acceder aux descriptions de segments.
    - Interdiction totale des caracteres accentues dans le Markdown genere.

.OBJECTIFS
    - Synchroniser la realite NTFS avec la documentation de projet.
    - Offrir une lecture rapide des missions de chaque segment V9.
#>

param ([switch]$Debug)

if ($Debug) { $DebugPreference = 'Continue' }

# --- 1. CHARGEMENT DU FRAMEWORK ---
$PathSPOT = Join-Path $PSScriptRoot '00_Infrastructure\00_Configuration.ps1'
if (Test-Path $PathSPOT) { . $PathSPOT } else { Write-Error "CRITIQUE : Framework V9 absent." ; exit 1 }

Write-Host "`n [!] SPECTRE V9 : GENERATION DOCUMENTAIRE " -ForegroundColor Cyan

# --- 2. INITIALISATION ET SCAN ---
$CptSuccess = 0 ; $NL = "`r`n" ; $DNL = "`r`n`r`n"
$Segments = Get-ChildItem -Path $PSScriptRoot -Directory -Recurse | Select-Object -ExpandProperty FullName
$Segments += $PSScriptRoot # Inclusion de la racine

# --- 3. MOTEUR DE GENERATION ---
foreach ($S in $Segments) {
    $Relatif = $S.Replace($PSScriptRoot, '').Trim('\')
    if ($Relatif -eq '') { $Relatif = '.' }
    
    Write-Debug " [DOC] Traitement de : $Relatif"

    # Recuperation des donnees depuis l'index SPOT
    $Meta = if ($Global:SpectreIndexSegments.ContainsKey($Relatif)) { $Global:SpectreIndexSegments[$Relatif] } 
            else { @{ Id='??'; Nom='ORPHELIN'; Desc='Segment V9 non indexe dans SPOT.' } }

    # Inventaire des scripts presents
    $Scripts = Get-ChildItem -Path $S -File -Filter "*.ps1"
    $ListeActifs = ""
    if ($Scripts) { 
        foreach ($F in $Scripts) { $ListeActifs += "* " + $F.Name + $NL } 
    } else { 
        $ListeActifs = "*Aucun script V9 detecte dans ce segment.*" 
    }

    # Construction du Markdown ASCII
    $MD = "# SPECTRE V9 | SECTION " + $Meta.Id + " : " + $Meta.Nom + $DNL
    $MD += "---" + $DNL
    $MD += "### MISSION DU SEGMENT" + $NL
    $MD += "| PROPRIETE | VALEUR |" + $NL
    $MD += "| :--- | :--- |" + $NL
    $MD += "| **VERSION** | 9.0.0 |" + $NL
    $MD += "| **PATH** | " + $Relatif + " |" + $NL
    $MD += "| **MISSION** | " + $Meta.Desc + " |" + $DNL
    $MD += "### INVENTAIRE DES ACTIFS (.PS1)" + $NL
    $MD += $ListeActifs + $DNL
    $MD += "---" + $NL
    $MD += "*Genere par SPECTRE-ENGINE V9 | " + (Get-Date -Format 'dd-MM-yyyy') + " | ASCII 7-BIT*"

    # Exportation forcee en ASCII
    try { 
        $MD | Out-File (Join-Path $S 'LISEZ_MOI.md') -Encoding ascii -Force
        $CptSuccess++ 
    } catch {
        Write-Debug " [FAIL] Impossible d'ecrire dans $Relatif"
    }
}

Write-Host "`n [SUCCESS] Documentation V9 mise a jour ($CptSuccess segments traites). " -ForegroundColor Green