<# NOM : 007_HW_DISK_SCSI_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\HARDWARE\DeviceMap\Scsi\*" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\HARDWARE\DeviceMap\Scsi\*" -Name "Identifier" -ErrorAction SilentlyContinue
        if ($null -eq $Val."Identifier") {
            Write-Host "[!!] ID:007_HW_DISK_SCSI | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."Identifier"
        if ("$Current" -eq "ST1000LM035") { Write-Host "[OK] ID:007_HW_DISK_SCSI | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:007_HW_DISK_SCSI | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 007_HW_DISK_SCSI : $($_.Exception.Message)" }
