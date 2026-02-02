<# NOM : 020_HW_THERMAL_ZONE_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\HARDWARE\ACPI\ThermalZone\TZ01" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\HARDWARE\ACPI\ThermalZone\TZ01" -Name "Temperature" -ErrorAction SilentlyContinue
        if ($null -eq $Val."Temperature") {
            Write-Host "[!!] ID:020_HW_THERMAL_ZONE | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."Temperature"
        if ("$Current" -eq "3100") { Write-Host "[OK] ID:020_HW_THERMAL_ZONE | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:020_HW_THERMAL_ZONE | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 020_HW_THERMAL_ZONE : $($_.Exception.Message)" }
