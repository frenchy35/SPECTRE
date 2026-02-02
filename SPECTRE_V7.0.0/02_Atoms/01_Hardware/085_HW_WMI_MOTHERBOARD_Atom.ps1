<# NOM : 085_HW_WMI_MOTHERBOARD_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\HARDWARE\Description\System" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\HARDWARE\Description\System" -Name "BaseBoardProduct" -ErrorAction SilentlyContinue
        if ($null -eq $Val."BaseBoardProduct") {
            Write-Host "[!!] ID:085_HW_WMI_MOTHERBOARD | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."BaseBoardProduct"
        if ("$Current" -eq "0X966A") { Write-Host "[OK] ID:085_HW_WMI_MOTHERBOARD | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:085_HW_WMI_MOTHERBOARD | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 085_HW_WMI_MOTHERBOARD : $($_.Exception.Message)" }
