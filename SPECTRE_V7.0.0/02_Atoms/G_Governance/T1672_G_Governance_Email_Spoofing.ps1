<#
.DESCRIPTION
    Atome SPECTRE pour MitreID : T1672
    Nom : Email Spoofing
    Categorie : G_Governance
#>

function Invoke-AtomeDebug {
    param([string]$Message)
    Write-Host "[(Get-Date -Format 'HH:mm:ss')][DEBUG][T1672] $Message" -ForegroundColor Gray
}

Invoke-AtomeDebug "Initialisation de l atome..."
# TODO : Integrer la logique de durcissement ou de deception ici.
