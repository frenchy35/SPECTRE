<#
.DESCRIPTION
    Atome SPECTRE pour MitreID : T1021.005
    Nom : VNC
    Categorie : S_Silicon
#>

function Invoke-AtomeDebug {
    param([string]$Message)
    Write-Host "[(Get-Date -Format 'HH:mm:ss')][DEBUG][T1021.005] $Message" -ForegroundColor Gray
}

Invoke-AtomeDebug "Initialisation de l atome..."
# TODO : Integrer la logique de durcissement ou de deception ici.
