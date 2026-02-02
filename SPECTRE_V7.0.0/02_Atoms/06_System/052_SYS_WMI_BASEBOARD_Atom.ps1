<# NOM : 052_SYS_WMI_BASEBOARD_Atom.ps1 | FAMILLE : 06_System #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\HARDWARE\Description\System" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\HARDWARE\Description\System" -Name "BaseBoardSerialNumber" -ErrorAction SilentlyContinue
        if ($null -eq $Val."BaseBoardSerialNumber") {
            Write-Host "[!!] ID:052_SYS_WMI_BASEBOARD | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."BaseBoardSerialNumber"
        if ("$Current" -eq "ABC-987654321") { Write-Host "[OK] ID:052_SYS_WMI_BASEBOARD | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:052_SYS_WMI_BASEBOARD | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 052_SYS_WMI_BASEBOARD : $($_.Exception.Message)" }
