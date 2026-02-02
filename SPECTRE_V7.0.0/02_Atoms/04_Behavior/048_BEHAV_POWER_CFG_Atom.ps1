<# NOM : 048_BEHAV_POWER_CFG_Atom.ps1 | FAMILLE : 04_Behavior #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes" -Name "ActivePowerScheme" -ErrorAction SilentlyContinue
        if ($null -eq $Val."ActivePowerScheme") {
            Write-Host "[!!] ID:048_BEHAV_POWER_CFG | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."ActivePowerScheme"
        if ("$Current" -eq "381b4222-f694-41f0-9685-ff5bb260df2e") { Write-Host "[OK] ID:048_BEHAV_POWER_CFG | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:048_BEHAV_POWER_CFG | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 048_BEHAV_POWER_CFG : $($_.Exception.Message)" }
