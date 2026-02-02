<# NOM : 135_HW_WMI_SERIAL_NUM_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\HARDWARE\Description\System" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\HARDWARE\Description\System" -Name "EnclosureSerialNumber" -ErrorAction SilentlyContinue
        if ($null -eq $Val."EnclosureSerialNumber") {
            Write-Host "[!!] ID:135_HW_WMI_SERIAL_NUM | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."EnclosureSerialNumber"
        if ("$Current" -eq "CZC1234567") { Write-Host "[OK] ID:135_HW_WMI_SERIAL_NUM | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:135_HW_WMI_SERIAL_NUM | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 135_HW_WMI_SERIAL_NUM : $($_.Exception.Message)" }
