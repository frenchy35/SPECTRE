<#
.DESCRIPTION
    Atome SPECTRE pour MitreID : T1048.003
    Nom : Exfiltration Over Unencrypted Non-C2 Protocol
    Categorie : G_Governance
#>

function Invoke-AtomeDebug {
    param([string]$Message)
    Write-Host "[(Get-Date -Format 'HH:mm:ss')][DEBUG][T1048.003] $Message" -ForegroundColor Gray
}

Invoke-AtomeDebug "Initialisation de l atome..."
# TODO : Integrer la logique de durcissement ou de deception ici.
