<# NOM : 051_SYS_DEBUG_PORT_REG_Atom.ps1 | FAMILLE : 06_System #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name "ProtectionMode" -ErrorAction SilentlyContinue
        if ($null -eq $Val."ProtectionMode") {
            Write-Host "[!!] ID:051_SYS_DEBUG_PORT_REG | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."ProtectionMode"
        if ("$Current" -eq "1") { Write-Host "[OK] ID:051_SYS_DEBUG_PORT_REG | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:051_SYS_DEBUG_PORT_REG | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 051_SYS_DEBUG_PORT_REG : $($_.Exception.Message)" }
