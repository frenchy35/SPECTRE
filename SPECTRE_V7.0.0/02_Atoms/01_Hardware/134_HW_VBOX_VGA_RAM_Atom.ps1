<# NOM : 134_HW_VBOX_VGA_RAM_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Control\Video\*\0000" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Video\*\0000" -Name "HardwareInformation.MemorySize" -ErrorAction SilentlyContinue
        if ($null -eq $Val."HardwareInformation.MemorySize") {
            Write-Host "[!!] ID:134_HW_VBOX_VGA_RAM | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."HardwareInformation.MemorySize"
        if ("$Current" -eq "1073741824") { Write-Host "[OK] ID:134_HW_VBOX_VGA_RAM | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:134_HW_VBOX_VGA_RAM | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 134_HW_VBOX_VGA_RAM : $($_.Exception.Message)" }
