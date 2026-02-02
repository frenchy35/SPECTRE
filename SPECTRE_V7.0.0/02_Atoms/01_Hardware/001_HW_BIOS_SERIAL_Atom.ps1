<# NOM : 001_HW_BIOS_SERIAL_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\HARDWARE\Description\System" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\HARDWARE\Description\System" -Name "SystemBiosDate" -ErrorAction SilentlyContinue
        if ($null -eq $Val."SystemBiosDate") {
            Write-Host "[!!] ID:001_HW_BIOS_SERIAL | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."SystemBiosDate"
        if ("$Current" -eq "05/12/23") { Write-Host "[OK] ID:001_HW_BIOS_SERIAL | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:001_HW_BIOS_SERIAL | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 001_HW_BIOS_SERIAL : $($_.Exception.Message)" }
