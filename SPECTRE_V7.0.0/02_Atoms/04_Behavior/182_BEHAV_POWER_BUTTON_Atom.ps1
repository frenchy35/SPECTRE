<# NOM : 182_BEHAV_POWER_BUTTON_Atom.ps1 | FAMILLE : 04_Behavior #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes" -Name "ButtonAction" -ErrorAction SilentlyContinue
        if ($null -eq $Val."ButtonAction") {
            Write-Host "[!!] ID:182_BEHAV_POWER_BUTTON | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."ButtonAction"
        if ("$Current" -eq "0") { Write-Host "[OK] ID:182_BEHAV_POWER_BUTTON | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:182_BEHAV_POWER_BUTTON | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 182_BEHAV_POWER_BUTTON : $($_.Exception.Message)" }
