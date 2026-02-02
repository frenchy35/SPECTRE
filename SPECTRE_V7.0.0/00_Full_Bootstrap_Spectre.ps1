<#
.DESCRIPTION
    NOM : bootstrap_v7.ps1
    VERSION : 7.1.2
    [CORRECTIF] : Ancrage dynamique sur PSScriptRoot pour une creation locale stricte.
    [CONTRAINTES] : Zero accent. Encodage ASCII. Structure ISO-13.
#>

$VerbosePreference = "Continue"

# 1. RECUPERATION DU DOSSIER LOCAL DU SCRIPT
$BaseDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
Write-Host "[INIT] Racine detectee : $BaseDir" -ForegroundColor Gray

# 2. DEFINITION DE LA STRUCTURE DES DOSSIERS
$RelativeFolders = @(
    "00_Core",
    "01_SSoT",
    "02_Atoms\G_Governance", "02_Atoms\S_Silicon", "02_Atoms\P_Privacy", 
    "02_Atoms\D_Defense", "02_Atoms\N_Network", "02_Atoms\U_User",
    "03_Engine",
    "04_Vault",
    "05_Factory\Generator",
    "06_Out\Logs", "06_Out\Reports", "06_Out\Backups",
    "07_Docs\Technical", "07_Docs\Security_Standard", "07_Docs\Changelogs"
)

Write-Host "`n" + ("="*60) -ForegroundColor Cyan
Write-Host "      SPECTRE V7.1.2 : INITIALISATION LOCALE" -ForegroundColor Cyan
Write-Host ("="*60) -ForegroundColor Cyan

# --- PHASE 1 : CREATION DES DOSSIERS ---
foreach ($RF in $RelativeFolders) {
    $FullPath = Join-Path $BaseDir $RF
    if (-not (Test-Path $FullPath)) {
        New-Item -Path $FullPath -ItemType Directory -Force | Out-Null
        Write-Host "[OK] Dossier cree : $RF" -ForegroundColor Green
    }
}

# --- PHASE 2 : INITIALISATION DES FICHIERS TEMPLATES ---
$Templates = @{
    "00_Core\Spectre_Shared_Lib.psm1" = "function Get-SpectrePointRef { param(`$ID) return `$null }`n# Fin de Lib"
    "01_SSoT\Master_SSoT.json"       = "{`n  `"Version`": `"7.1.2`",`n  `"KnowledgePoints`": []`n}"
    "07_Docs\Technical\STRUCTURE.md" = "# Architecture SPECTRE V7.1.2`n`n[Reference de l arborescence]"
    "07_Docs\Changelogs\VERSION.txt" = "2026-01-16 | V7.1.2 | Initialisation locale du projet."
}

foreach ($RelPath in $Templates.Keys) {
    $FullPath = Join-Path $BaseDir $RelPath
    if (-not (Test-Path $FullPath)) {
        # Encodage ASCII pour respecter la contrainte Zero Accent
        $Templates[$RelPath] | Out-File -FilePath $FullPath -Encoding ascii -Force
        Write-Host "[OK] Fichier initialise : $RelPath" -ForegroundColor Yellow
    }
}

Write-Host "`n[FIN] Structure V7.1.2 creee avec succes dans : $BaseDir" -ForegroundColor Cyan