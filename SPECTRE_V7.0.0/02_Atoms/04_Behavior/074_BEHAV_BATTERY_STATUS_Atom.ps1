<# NOM : 074_BEHAV_BATTERY_STATUS_Atom.ps1 | FAMILLE : 04_Behavior #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Control\Power" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power" -Name "BatteryLevel" -ErrorAction SilentlyContinue
        if ($null -eq $Val."BatteryLevel") {
            Write-Host "[!!] ID:074_BEHAV_BATTERY_STATUS | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."BatteryLevel"
        if ("$Current" -eq "100") { Write-Host "[OK] ID:074_BEHAV_BATTERY_STATUS | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:074_BEHAV_BATTERY_STATUS | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 074_BEHAV_BATTERY_STATUS : $($_.Exception.Message)" }
