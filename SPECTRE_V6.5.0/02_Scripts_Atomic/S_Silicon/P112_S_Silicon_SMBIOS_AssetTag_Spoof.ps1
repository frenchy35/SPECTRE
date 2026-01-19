<#
    ID: 112 | Name: SMBIOS_AssetTag_Spoof
    Artifact de comportement : V4.9.3 Lock
    Description : Injection d'un Asset Tag realiste pour SMBIOS
#>
[CmdletBinding()]
param([Switch]$Analyse, [Switch]$Commit, [Switch]$Rollback, [Switch]$DebugInfo, $CustomValue = $null)

$StartTime = [System.Diagnostics.Stopwatch]::StartNew()
$LibPath = Join-Path $PSScriptRoot "..\..\04_Tools_Lib\Spectre_Shared_Lib.psm1"
Import-Module $LibPath -Force
$Context = Get-SpectrePointRef -PointID "112"

Write-Host "`n[ATOME 112] SMBIOS_AssetTag_Spoof" -ForegroundColor Cyan
$FinalTarget = if ($null -ne $CustomValue) { $CustomValue } else { if($Rollback){$Context.RollbackValue} else {$Context.TargetValue} }

$CurrentObj = Get-ItemProperty -Path $Context.RegPath -Name $Context.ValueName -ErrorAction SilentlyContinue
$CurrentVal = if($null -eq $CurrentObj.$($Context.ValueName)){'MISSING'}else{$CurrentObj.$($Context.ValueName)}

Write-Host "  [STATE] Current   : $CurrentVal" -ForegroundColor White
Write-Host "  [STATE] Target    : $FinalTarget" -ForegroundColor White

if ($Analyse) {
    $Status = if($CurrentVal -eq $FinalTarget){"ALREADY_CONFORM"}else{"NON_CONFORM"}
    return [PSCustomObject]@{ID="112"; Name="SMBIOS_AssetTag_Spoof"; Status="ANALYSE_$Status"; Updated=$false}
}

$Result = Invoke-SpectreRegistryTransaction -Context $Context -Commit:$Commit -Rollback:$Rollback
$StartTime.Stop()
Write-Host "  [RESULT] Status    : $($Result.Status) ($($StartTime.Elapsed.TotalMilliseconds) ms)" -ForegroundColor Gray
return $Result
