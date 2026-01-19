<#
.DESCRIPTION
    Atome SPECTRE pour MitreID : T1137.004
    Nom : Outlook Home Page
    Categorie : G_Governance
#>

function Invoke-AtomeDebug {
    param([string]$Message)
    Write-Host "[(Get-Date -Format 'HH:mm:ss')][DEBUG][T1137.004] $Message" -ForegroundColor Gray
}

Invoke-AtomeDebug "Initialisation de l atome..."
# TODO : Integrer la logique de durcissement ou de deception ici.
