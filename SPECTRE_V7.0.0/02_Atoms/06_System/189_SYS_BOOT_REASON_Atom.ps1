<# NOM : 189_SYS_BOOT_REASON_Atom.ps1 | FAMILLE : 06_System #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "LastSleepWakeTime" -ErrorAction SilentlyContinue
        if ($null -eq $Val."LastSleepWakeTime") {
            Write-Host "[!!] ID:189_SYS_BOOT_REASON | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."LastSleepWakeTime"
        if ("$Current" -eq "0") { Write-Host "[OK] ID:189_SYS_BOOT_REASON | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:189_SYS_BOOT_REASON | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 189_SYS_BOOT_REASON : $($_.Exception.Message)" }
