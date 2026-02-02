<#
.DESCRIPTION
    NOM : Generate_Atom_Stubs.ps1
    VERSION : 1.0.0
    Role : Cree les fichiers .ps1 vides pour chaque technique dans 02_Atoms.
    [CONTRAINTES] : Zero accent. Encodage ASCII. Debug function. Debug integre dans chaque atome.
#>

function Invoke-SpectreDebug {
    param([string]$Message, [string]$Type = "INFO")
    $Timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$Timestamp][$Type] $Message" -ForegroundColor Gray
}

$PSScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }
$ProjectRoot = Split-Path -Path $PSScriptRoot -Parent
$SSoTFolder = Join-Path $ProjectRoot "01_SSoT"
$AtomsFolder = Join-Path $ProjectRoot "02_Atoms"

$JsonFiles = Get-ChildItem -Path $SSoTFolder -Filter "*.json"

foreach ($File in $JsonFiles) {
    $Data = Get-Content -Path $File.FullName | ConvertFrom-Json
    $Category = $Data.Header.Category
    $TargetDir = Join-Path $AtomsFolder $Category

    if (-not (Test-Path $TargetDir)) { New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null }

    Invoke-SpectreDebug "Traitement de la categorie : $Category"

    foreach ($Control in $Data.Controls) {
        # Nettoyage du nom pour le systeme de fichiers
        $CleanName = $Control.Name -replace '[^a-zA-Z0-9]', '_'
        $FileName = "$($Control.MitreID)_$($Category)_$($CleanName).ps1"
        $FilePath = Join-Path $TargetDir $FileName

        if (-not (Test-Path $FilePath)) {
            $Content = @"
<#
.DESCRIPTION
    Atome SPECTRE pour MitreID : $($Control.MitreID)
    Nom : $($Control.Name)
    Categorie : $Category
#>

function Invoke-AtomeDebug {
    param([string]`$Message)
    Write-Host "[(Get-Date -Format 'HH:mm:ss')][DEBUG][$($Control.MitreID)] `$Message" -ForegroundColor Gray
}

Invoke-AtomeDebug "Initialisation de l atome..."
# TODO : Integrer la logique de durcissement ou de deception ici.
"@
            $Content | Out-File -FilePath $FilePath -Encoding ascii
        }
    }
}

Invoke-SpectreDebug "Generation des stubs terminee dans 02_Atoms." "SUCCESS"