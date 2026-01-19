<#
    ID: 419 | Name: Teredo_Interface_Disable
    MITRE: T1012 | Severity: 
    Compliance: 
    Artifact de comportement : V4.9.3 Lock
#>
[CmdletBinding()]
param([Switch]$Commit, [Switch]$Rollback, [Switch]$DebugInfo)

$StartTime = [System.Diagnostics.Stopwatch]::StartNew()
Import-Module "..\\..\\04_Tools_Lib\\Spectre_Shared_Lib.psm1" -Force

$Context = Get-SpectrePointRef -PointID "419"
if ($null -eq $Context) { Write-Error "[FATAL] Context Failure 419"; return }

# --- HEADER VERBOSE (14 ITEMS) ---
Write-Host "`n[ATOME 419] Teredo_Interface_Disable" -ForegroundColor Cyan
Write-Host "  [META] Group/Sub  : $($Context.Group) / $($Context.SubGroup)" -ForegroundColor Gray
Write-Host "  [META] Mitre/Sev  : $($Context.MitreID) / $($Context.Severity)" -ForegroundColor Gray
Write-Host "  [META] Standard   : $($Context.ComplianceStandard)" -ForegroundColor Gray
Write-Host "  [DESC] Info       : $($Context.Description)" -ForegroundColor DarkGray
Write-Host "  [TARGET] Registry : $($Context.RegPath)" -ForegroundColor Gray
Write-Host "  [TARGET] Property : $($Context.ValueName) ($($Context.ValueType))" -ForegroundColor Gray

# --- AUDIT PRE-ACTION ---
$CurrentValue = (Get-ItemProperty -Path $Context.RegPath -Name $Context.ValueName -ErrorAction SilentlyContinue).$($Context.ValueName)
$TargetValue = if ($Rollback) { $Context.RollbackValue } else { $Context.TargetValue }

Write-Host "  [STATE] Current   : $(if($null -eq $CurrentValue){'MISSING'}else{$CurrentValue})" -ForegroundColor White
Write-Host "  [STATE] Target    : $TargetValue" -ForegroundColor White

# --- EXECUTION ---
if ($DebugInfo) { Write-Host "[DEBUG] Invoking Transaction Engine..." -ForegroundColor Magenta }
$Result = Invoke-SpectreRegistryTransaction -Context $Context -Commit:$Commit -Rollback:$Rollback

$StartTime.Stop()
$FinalColor = if($Result.Status -match "SUCCESS|ALREADY_CONFORM") { "Green" } else { "Yellow" }

Write-Host "  [RESULT] Status   : $($Result.Status)" -ForegroundColor $FinalColor
Write-Host "  [RESULT] Latency  : $($StartTime.Elapsed.TotalMilliseconds) ms" -ForegroundColor Gray
Write-Host "----------------------------------------------------"

return $Result
