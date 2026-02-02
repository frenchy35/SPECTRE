<#
.DESCRIPTION
    BOOTSTRAP TOTAL SPECTRE V6.5.0
    Execute ce script a la racine du dossier SPECTRE_V6.5.0.
    Cree l'arborescence et les fichiers templates (vides) conformes ISO-13.
#>

$VerbosePreference = "Continue"

# 1. DEFINITION DE LA STRUCTURE DES DOSSIERS
$Folders = @(
    "01_Profiles",
    "02_Scripts_Atomic\G_Governance",
    "02_Scripts_Atomic\S_Silicon",
    "02_Scripts_Atomic\P_Privacy",
    "02_Scripts_Atomic\D_Defense",
    "02_Scripts_Atomic\N_Network",
    "02_Scripts_Atomic\U_User",
    "03_Orchestrators",
    "04_Tools_Lib",
    "05_DevTools",
    "06_Logs"
)

# 2. DEFINITION DES FICHIERS CRITIQUES (TEMPLATES)
$Files = @(
    "01_Profiles\G_Governance.json",
    "01_Profiles\S_Silicon.json",
    "01_Profiles\P_Privacy.json",
    "01_Profiles\D_Defense.json",
    "01_Profiles\N_Network.json",
    "01_Profiles\U_User.json",
    "03_Orchestrators\Orchestrator_G_Governance.ps1",
    "03_Orchestrators\Orchestrator_S_Silicon.ps1",
    "03_Orchestrators\Orchestrator_P_Privacy.ps1",
    "03_Orchestrators\Orchestrator_D_Defense.ps1",
    "03_Orchestrators\Orchestrator_N_Network.ps1",
    "03_Orchestrators\Orchestrator_U_User.ps1",
    "04_Tools_Lib\Spectre_Shared_Lib.psm1",
    "05_DevTools\Factory_V3.5.ps1"
)

Write-Host "--- SPECTRE V6.5.0 : INITIALISATION DE L'INFRASTRUCTURE ---" -ForegroundColor Cyan

# Creation des dossiers
foreach ($F in $Folders) {
    if (-not (Test-Path $F)) {
        New-Item -Path $F -ItemType Directory -Force | Out-Null
        Write-Host "[OK] Dossier Cree : $F" -ForegroundColor Green
    }
}

# Creation des fichiers templates s'ils n'existent pas
foreach ($File in $Files) {
    if (-not (Test-Path $File)) {
        $Header = "<# TEMPLATE SPECTRE - INITIALISE LE $(Get-Date) #>"
        if ($File -like "*.json") { $Header = "{ `"GroupName`": `"TO_BE_DEFINED`", `"KnowledgePoints`": [] }" }
        
        New-Item -Path $File -ItemType File -Value $Header -Force | Out-Null
        Write-Host "[OK] Fichier Initialise : $File" -ForegroundColor Yellow
    }
}

Write-Host "`nStructure prete. Veuillez remplir les fichiers .json et la Lib." -ForegroundColor Cyan