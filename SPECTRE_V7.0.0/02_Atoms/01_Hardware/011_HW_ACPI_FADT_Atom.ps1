<# NOM : 011_HW_ACPI_FADT_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\HARDWARE\ACPI\FADT\*" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\HARDWARE\ACPI\FADT\*" -Name "OEMID" -ErrorAction SilentlyContinue
        if ($null -eq $Val."OEMID") {
            Write-Host "[!!] ID:011_HW_ACPI_FADT | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."OEMID"
        if ("$Current" -eq "INTEL ") { Write-Host "[OK] ID:011_HW_ACPI_FADT | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:011_HW_ACPI_FADT | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 011_HW_ACPI_FADT : $($_.Exception.Message)" }
