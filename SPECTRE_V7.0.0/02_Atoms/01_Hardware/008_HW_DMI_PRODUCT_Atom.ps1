<# NOM : 008_HW_DMI_PRODUCT_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\HARDWARE\Description\System" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\HARDWARE\Description\System" -Name "SystemProductName" -ErrorAction SilentlyContinue
        if ($null -eq $Val."SystemProductName") {
            Write-Host "[!!] ID:008_HW_DMI_PRODUCT | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."SystemProductName"
        if ("$Current" -eq "OptiPlex 7080") { Write-Host "[OK] ID:008_HW_DMI_PRODUCT | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:008_HW_DMI_PRODUCT | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 008_HW_DMI_PRODUCT : $($_.Exception.Message)" }
