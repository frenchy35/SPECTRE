<# NOM : 018_HW_USB_HUB_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Enum\USB\ROOT_HUB*" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\USB\ROOT_HUB*" -Name "DeviceDesc" -ErrorAction SilentlyContinue
        if ($null -eq $Val."DeviceDesc") {
            Write-Host "[!!] ID:018_HW_USB_HUB | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."DeviceDesc"
        if ("$Current" -eq "USB Root Hub (USB 3.0)") { Write-Host "[OK] ID:018_HW_USB_HUB | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:018_HW_USB_HUB | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 018_HW_USB_HUB : $($_.Exception.Message)" }
