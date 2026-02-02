<# NOM : 089_HW_USB_CONTROLLER_ID_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Enum\PCI\VEN_8086&DEV_A12F" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI\VEN_8086&DEV_A12F" -Name "DeviceDesc" -ErrorAction SilentlyContinue
        if ($null -eq $Val."DeviceDesc") {
            Write-Host "[!!] ID:089_HW_USB_CONTROLLER_ID | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."DeviceDesc"
        if ("$Current" -eq "Intel(R) USB 3.0 eXtensible Host Controller") { Write-Host "[OK] ID:089_HW_USB_CONTROLLER_ID | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:089_HW_USB_CONTROLLER_ID | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 089_HW_USB_CONTROLLER_ID : $($_.Exception.Message)" }
