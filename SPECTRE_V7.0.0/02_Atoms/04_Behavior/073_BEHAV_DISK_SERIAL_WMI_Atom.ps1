<# NOM : 073_BEHAV_DISK_SERIAL_WMI_Atom.ps1 | FAMILLE : 04_Behavior #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\HARDWARE\DEVICEMAP\Scsi\Scsi Port 0\*" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\HARDWARE\DEVICEMAP\Scsi\Scsi Port 0\*" -Name "SerialNumber" -ErrorAction SilentlyContinue
        if ($null -eq $Val."SerialNumber") {
            Write-Host "[!!] ID:073_BEHAV_DISK_SERIAL_WMI | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."SerialNumber"
        if ("$Current" -eq "ST500DM002") { Write-Host "[OK] ID:073_BEHAV_DISK_SERIAL_WMI | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:073_BEHAV_DISK_SERIAL_WMI | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 073_BEHAV_DISK_SERIAL_WMI : $($_.Exception.Message)" }
