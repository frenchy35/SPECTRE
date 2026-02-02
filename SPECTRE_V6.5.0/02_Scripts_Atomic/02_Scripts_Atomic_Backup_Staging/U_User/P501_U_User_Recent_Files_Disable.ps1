<#
    ID: 501 | Name: Recent_Files_Disable
    Artifact de comportement : V4.9.3 Lock
#>
[CmdletBinding()]
param([Switch]$Commit, [Switch]$Rollback, [Switch]$DebugInfo)

$StartTime = [System.Diagnostics.Stopwatch]::StartNew()

# Resolution absolue du chemin de la Lib
$LibPath = Join-Path $PSScriptRoot "..\..\04_Tools_Lib\Spectre_Shared_Lib.psm1"
if (-not (Test-Path $LibPath)) {
    Write-Error "[FATAL] Librairie introuvable au chemin : $LibPath"
    return
}
Import-Module $LibPath -Force

$Context = Get-SpectrePointRef -PointID "501"
if ($null -eq $Context) { Write-Error "[FATAL] Liaison SSOT echouee pour ID 501"; return }

Write-Host "`n[ATOME 501] Recent_Files_Disable" -ForegroundColor Cyan

# Affichage des descripteurs ISO-13
$Map = [ordered]@{
    "ID/MITRE"   = "$($Context.ID) / $($Context.MitreID)"
    "GROUP/SUB"  = "$($Context.Group) / $($Context.SubGroup)"
    "SEVERITY"   = "$($Context.Severity)"
    "STANDARD"   = "$($Context.ComplianceStandard)"
    "DESC"       = "$($Context.Description)"
    "REGISTRY"   = "$($Context.RegPath)"
    "VALUE/TYPE" = "$($Context.ValueName) ($($Context.ValueType))"
}

foreach ($K in $Map.Keys) { Write-Host "  [META] $($K.PadRight(10)) : $($Map[$K])" -ForegroundColor Gray }

$Current = (Get-ItemProperty -Path $Context.RegPath -Name $Context.ValueName -ErrorAction SilentlyContinue).$($Context.ValueName)
Write-Host "  [STATE] Current    : $(if($null -eq $Current){'MISSING'}else{$Current})" -ForegroundColor White

$Result = Invoke-SpectreRegistryTransaction -Context $Context -Commit:$Commit -Rollback:$Rollback

$StartTime.Stop()
$Color = if($Result.Status -match "SUCCESS|CONFORM") { "Green" } else { "Yellow" }
Write-Host "  [RESULT] Status    : $($Result.Status)" -ForegroundColor $Color
Write-Host "  [RESULT] Latency   : $($StartTime.Elapsed.TotalMilliseconds) ms" -ForegroundColor Gray
Write-Host "----------------------------------------------------"

return $Result
