<# NOM : 056_HW_MONITOR_MANUF_ID_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Enum\DISPLAY\*\Device Parameters" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\DISPLAY\*\Device Parameters" -Name "EDID" -ErrorAction SilentlyContinue
        if ($null -eq $Val."EDID") {
            Write-Host "[!!] ID:056_HW_MONITOR_MANUF_ID | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."EDID"
        if ("$Current" -eq "") { Write-Host "[OK] ID:056_HW_MONITOR_MANUF_ID | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:056_HW_MONITOR_MANUF_ID | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 056_HW_MONITOR_MANUF_ID : $($_.Exception.Message)" }
