<# NOM : 009_HW_DMI_MANUF_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\HARDWARE\Description\System" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\HARDWARE\Description\System" -Name "SystemManufacturer" -ErrorAction SilentlyContinue
        if ($null -eq $Val."SystemManufacturer") {
            Write-Host "[!!] ID:009_HW_DMI_MANUF | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."SystemManufacturer"
        if ("$Current" -eq "Dell Inc.") { Write-Host "[OK] ID:009_HW_DMI_MANUF | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:009_HW_DMI_MANUF | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 009_HW_DMI_MANUF : $($_.Exception.Message)" }
