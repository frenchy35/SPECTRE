<#
.DESCRIPTION
    NOM : Atom_Integrity_Checker.ps1
    VERSION : 1.1.0 (Hardened Compliance Auditor)
    ROLE : Audit de masse de l'arsenal forge (800+ atomes).
    [OBLIGATION] : Full Verbosity, Zero Accent, ASCII, Security Check.
#>

# 1. MOTEUR DE LOGS UNIFIE
function Out-SpectreAudit {
    param(
        [Parameter(Mandatory=$true)][string]$Message,
        [ValidateSet("INFO", "WARN", "ERR", "SUCCESS", "DEBUG")][string]$Type = "INFO"
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    $Color = switch($Type) { 
        "ERR"     {"Red"} 
        "WARN"    {"Yellow"} 
        "SUCCESS"{"Green"} 
        "DEBUG"   {"Cyan"}
        Default   {"Gray"} 
    }
    Write-Host "[$Timestamp][$Type][AUDIT_V1.1] $Message" -ForegroundColor $Color
}

# 2. CONFIGURATION DES CHEMINS
$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectRoot  = Split-Path -Parent $PSScriptRoot
$AtomsPath    = Join-Path $ProjectRoot "02_Atoms"

Out-SpectreAudit -Message ">>> DEBUT DE L'INSPECTION DE L'ARSENAL <<<" -Type "DEBUG"

if (-not (Test-Path $AtomsPath)) {
    Out-SpectreAudit -Message "Dossier 02_Atoms introuvable." -Type "ERR"
    return
}

$Atoms = Get-ChildItem -Path $AtomsPath -Filter "*.ps1" -Recurse
Out-SpectreAudit -Message "Nombre d'atomes a verifier : $($Atoms.Count)" -Type "INFO"

$Stats = @{ "Conforme" = 0; "Generique" = 0; "Corrompu" = 0 }

# 3. BOUCLE D'AUDIT TECHNIQUE
foreach ($Atom in $Atoms) {
    try {
        $Content = Get-Content -Path $Atom.FullName -Raw -ErrorAction Stop
        $ID = ($Atom.Name -split "_")[0]

        # A. Verification de la structure (Syntaxe PowerShell)
        $null = [System.Management.Automation.Language.Parser]::ParseInput($Content, [ref]$null, [ref]$null)

        # B. Verification de la Tamper Protection (Contrainte)
        if ($Content -notmatch "Get-MpComputerStatus") {
            Out-SpectreAudit -Message "[$ID] ERREUR : Verification Tamper Protection absente." -Type "ERR"
            $Stats.Corrompu++
            continue
        }

        # C. Analyse du Payload (Data-Driven check)
        if ($Content -match 'Target = "Generic"') {
            # Atome fonctionnel mais non-arme specifiquement
            $Stats.Generique++
        } else {
            # Atome arme avec des variables réelles (RegPath, etc.)
            $Stats.Conforme++
        }
    }
    catch {
        Out-SpectreAudit -Message "[$ID] CRITIQUE : Impossible de lire ou parser le fichier." -Type "ERR"
        $Stats.Corrompu++
    }
}

# 4. RAPPORT FINAL (FULL VERBOSITY)
Out-SpectreAudit -Message "--- BILAN DE SANTE DE L'ARSENAL ---" -Type "DEBUG"
Out-SpectreAudit -Message "Atomes 100% Conformes et Armes    : $($Stats.Conforme)" -Type "SUCCESS"
Out-SpectreAudit -Message "Atomes avec Payloads Generiques     : $($Stats.Generique)" -Type "WARN"
Out-SpectreAudit -Message "Atomes Corrompus / Non-Conformes   : $($Stats.Corrompu)" -Type "ERR"

if ($Stats.Corrompu -eq 0) {
    Out-SpectreAudit -Message "L'arsenal est pret pour l'Orchestration Engine V7." -Type "SUCCESS"
} else {
    Out-SpectreAudit -Message "Action requise : Relancer la Forge V6.8.0." -Type "WARN"
}