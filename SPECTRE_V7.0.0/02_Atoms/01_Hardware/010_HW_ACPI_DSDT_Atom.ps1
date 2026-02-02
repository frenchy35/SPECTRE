<# NOM : 010_HW_ACPI_DSDT_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\HARDWARE\ACPI\DSDT\VBOX__" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\HARDWARE\ACPI\DSDT\VBOX__" -Name "Name" -ErrorAction SilentlyContinue
        if ($null -eq $Val."Name") {
            Write-Host "[!!] ID:010_HW_ACPI_DSDT | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."Name"
        if ("$Current" -eq "VBOX") { Write-Host "[OK] ID:010_HW_ACPI_DSDT | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:010_HW_ACPI_DSDT | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 010_HW_ACPI_DSDT : $($_.Exception.Message)" }
