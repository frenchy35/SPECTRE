<# NOM : 002_HW_BIOS_VER_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\HARDWARE\Description\System" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\HARDWARE\Description\System" -Name "SystemBiosVersion" -ErrorAction SilentlyContinue
        if ($null -eq $Val."SystemBiosVersion") {
            Write-Host "[!!] ID:002_HW_BIOS_VER | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."SystemBiosVersion"
        if ("$Current" -eq "DELL - 2024") { Write-Host "[OK] ID:002_HW_BIOS_VER | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:002_HW_BIOS_VER | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 002_HW_BIOS_VER : $($_.Exception.Message)" }
