<#
.DESCRIPTION
    Atome SPECTRE pour MitreID : T1220
    Nom : XSL Script Processing
    Categorie : N_Network
#>

function Invoke-AtomeDebug {
    param([string]$Message)
    Write-Host "[(Get-Date -Format 'HH:mm:ss')][DEBUG][T1220] $Message" -ForegroundColor Gray
}

Invoke-AtomeDebug "Initialisation de l atome..."
# TODO : Integrer la logique de durcissement ou de deception ici.
