<# NOM : 111_HW_MONITOR_EDID_DATA_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Enum\DISPLAY\*\Device Parameters" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\DISPLAY\*\Device Parameters" -Name "EDID" -ErrorAction SilentlyContinue
        if ($null -eq $Val."EDID") {
            Write-Host "[!!] ID:111_HW_MONITOR_EDID_DATA | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."EDID"
        if ("$Current" -eq "00ffffffffffff00...") { Write-Host "[OK] ID:111_HW_MONITOR_EDID_DATA | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:111_HW_MONITOR_EDID_DATA | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 111_HW_MONITOR_EDID_DATA : $($_.Exception.Message)" }
