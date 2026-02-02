<# NOM : 084_HW_VBOX_SERIAL_COM_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\HARDWARE\DEVICEMAP\SERIALCOMM" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\HARDWARE\DEVICEMAP\SERIALCOMM" -Name "\Device\Serial0" -ErrorAction SilentlyContinue
        if ($null -eq $Val."\Device\Serial0") {
            Write-Host "[!!] ID:084_HW_VBOX_SERIAL_COM | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."\Device\Serial0"
        if ("$Current" -eq "COM1") { Write-Host "[OK] ID:084_HW_VBOX_SERIAL_COM | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:084_HW_VBOX_SERIAL_COM | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 084_HW_VBOX_SERIAL_COM : $($_.Exception.Message)" }
