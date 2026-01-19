<#
.DESCRIPTION
    Atome SPECTRE pour MitreID : 
    Nom : 
    Categorie : U_User
#>

function Invoke-AtomeDebug {
    param([string]$Message)
    Write-Host "[(Get-Date -Format 'HH:mm:ss')][DEBUG][] $Message" -ForegroundColor Gray
}

Invoke-AtomeDebug "Initialisation de l atome..."
# TODO : Integrer la logique de durcissement ou de deception ici.
