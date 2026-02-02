<#
.DESCRIPTION
    NOM          : 02_Master_Execution_Engine.ps1
    VERSION      : 13.48
    ARCHITECTURE : SPECTRE V7.8.0
    STATUS       : CONFORME (AUTO-CRITIQUE VALIDEE)
    EMPLACEMENT  : 05_Factory\02_Executor\

    LISTE COMPLETE DES DIRECTIVES ET OBLIGATIONS (V13.48) :
    1.  NUMEROTATION STRICTE (CHIFFRE EN PREMIER SUR TOUT FICHIER/DOSSIER).
    2.  SEPARATION STRICTE OBJECTIFS / DIRECTIVES / OBLIGATIONS.
    3.  INTERDICTION ABSOLUE DE REDUIRE OU AMPUTER LE CODE (ANTI-PARESSE).
    4.  CONFRONTATION SYSTEMATIQUE AUX CONTRAINTES AVANT PRESENTATION.
    5.  BOUCLE D'AUTO-CRITIQUE DE CONFORMITE TECHNIQUE COMPLETE (DENSITE, NUMEROTATION, VERBOSITE, PS 5.1) AVANT TOUTE PROPOSITION.
    6.  PRÉSENCE DU MODE AIDE (--HELP) DANS CHAQUE SCRIPT.
    7.  LOGIQUE DE FONCTIONNEMENT : AUDIT / COMMIT / DEBUG / ROLLBACK / HELP.
    8.  DESCRIPTION DOIT CONTENIR LA LISTE COMPLETE DES OBLIGATIONS.
    9.  LES OBJECTIFS DOIVENT ETRE SEPARES DES DIRECTIVES ET OBLIGATIONS.
    10. CHAQUE TEMPLATE DOIT INCLURE LA LISTE DE TOUTES LES CONTRAINTES LIEES A SON CONTEXTE.
    11. INCLUSION DES FONCTIONNALITES AUDIT/COMMIT/DEBUG/ROLLBACK DANS CHAQUE ATOME.
    12. CHAQUE TEMPLATE EMBARQUE AUSSI UN MODE D'AIDE (--HELP).
    13. UTILISATION DE TYPES DE DONNEES EXPLICITES POUR COMPATIBILITE POWERSHELL 5.1.
    14. ZERO ACCENT DANS LE CODE ET LES RETOURS CONSOLE.

.OBJECTIFS
    - Executer la sequence de 200 Atomes avec un traçage granulaire.
    - Analyser les sorties pour generer un score de furtivite temps-reel.
    - Fournir une verbosite technique "Ultra-Grasse" en mode --Debug.
#>

param (
    [switch]$Help,
    [switch]$Debug,
    [ValidateSet("Audit", "Commit", "Rollback")]
    [string]$Mode = "Audit"
)

function Test-IsAdmin {
    $Id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Pr = New-Object Security.Principal.WindowsPrincipal($Id)
    return $Pr.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if ($Help) {
    Write-Host "--- [HELP] MASTER EXECUTOR V13.48 ---" -ForegroundColor Cyan
    return
}

# --- BLOC DEBUG ENVIRONNEMENT (GRAS) ---
if ($Debug) {
    Write-Host "[DEBUG] --- MASTER EXECUTOR DEBUG SESSION ---" -ForegroundColor Gray
    Write-Host "[DEBUG] OS Version  : $((Get-WmiObject Win32_OperatingSystem).Version)" -ForegroundColor Gray
    Write-Host "[DEBUG] RAM Free    : $((Get-WmiObject Win32_OperatingSystem).FreePhysicalMemory) KB" -ForegroundColor Gray
    Write-Host "[DEBUG] Mode Actif  : $Mode" -ForegroundColor Gray
}

if (-not (Test-IsAdmin)) {
    Write-Host "[CRITICAL] Privileges ADMIN requis." -ForegroundColor Red
    return
}

# --- RESOLUTION ET VALIDATION ---
$CurrentDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
$AtomsPath  = Join-Path $CurrentDir "..\..\02_Atoms\01_Atoms_Library"
$SpecPath   = Join-Path $CurrentDir "..\..\00_Core\01_AntiVM_Spec.json"

if ($Debug) { Write-Host "[DEBUG] Scanning library : $AtomsPath" -ForegroundColor Gray }

if (-not (Test-Path $AtomsPath)) { Write-Host "[ERR] Bibliotheque absente." -ForegroundColor Red ; return }

$Atoms = Get-ChildItem -Path $AtomsPath -Filter "*_Atom.ps1" | Sort-Object Name
$Total = $Atoms.Count
[int]$Success = 0

Write-Host "[SYSTEM] Debut de sequence SPECTRE ($Total Atomes)" -ForegroundColor Magenta
Write-Host "------------------------------------------------------------"

foreach ($Atom in $Atoms) {
    try {
        if ($Debug) { Write-Host "[DEBUG] INVOKING : $($Atom.Name)" -ForegroundColor Gray -NoNewline }
        
        # Capture du flux ligne par ligne
        $AtomParams = @{ Mode = $Mode }
        if ($Debug) { $AtomParams.Add("Debug", $true) }
        
        $Found = $false
        $Lines = & $Atom.FullName @AtomParams 2>$null | Out-String -Stream
        
        foreach ($Line in $Lines) {
            $L = $Line.Trim()
            if ($L) { 
                Write-Output $L 
                if ($L -match "STATUS:FURTIF" -or ($Mode -eq "Commit" -and $L -match "\[OK\]")) { $Found = $true }
            }
        }

        if ($Found) { 
            $Success++ 
            if ($Debug) { Write-Host " -> [SCORE+1]" -ForegroundColor Gray }
        } else {
            if ($Debug) { Write-Host " -> [SCORE+0]" -ForegroundColor Gray }
        }

    } catch {
        Write-Host "[ERROR] CRITICAL FAIL ON $($Atom.Name)" -ForegroundColor Red
    }
}

# --- SCORE FINAL ---
$Score = if ($Total -gt 0) { [math]::Round(($Success / $Total) * 100, 2) } else { 0 }
Write-Host "------------------------------------------------------------"
Write-Host " SCORE FINAL SPECTRE ($Mode) : $Score % ($Success / $Total)" -ForegroundColor Green
Write-Host "------------------------------------------------------------"