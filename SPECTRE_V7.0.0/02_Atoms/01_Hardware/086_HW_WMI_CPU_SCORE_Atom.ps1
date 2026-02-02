<# NOM : 086_HW_WMI_CPU_SCORE_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0" -Name "L2CacheSize" -ErrorAction SilentlyContinue
        if ($null -eq $Val."L2CacheSize") {
            Write-Host "[!!] ID:086_HW_WMI_CPU_SCORE | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."L2CacheSize"
        if ("$Current" -eq "10240") { Write-Host "[OK] ID:086_HW_WMI_CPU_SCORE | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:086_HW_WMI_CPU_SCORE | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 086_HW_WMI_CPU_SCORE : $($_.Exception.Message)" }
