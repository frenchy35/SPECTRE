<#
.DESCRIPTION
    Atome SPECTRE pour MitreID : T1090
    Nom : Proxy
    Categorie : N_Network
#>

function Invoke-AtomeDebug {
    param([string]$Message)
    Write-Host "[(Get-Date -Format 'HH:mm:ss')][DEBUG][T1090] $Message" -ForegroundColor Gray
}

Invoke-AtomeDebug "Initialisation de l atome..."
# TODO : Integrer la logique de durcissement ou de deception ici.
