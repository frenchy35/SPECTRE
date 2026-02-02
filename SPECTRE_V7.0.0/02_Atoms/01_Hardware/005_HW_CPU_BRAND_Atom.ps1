<# NOM : 005_HW_CPU_BRAND_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\HARDWARE\Description\System\CentralProcessor\0" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\HARDWARE\Description\System\CentralProcessor\0" -Name "ProcessorNameString" -ErrorAction SilentlyContinue
        if ($null -eq $Val."ProcessorNameString") {
            Write-Host "[!!] ID:005_HW_CPU_BRAND | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."ProcessorNameString"
        if ("$Current" -eq "13th Gen Intel(R) Core(TM) i9-13900K") { Write-Host "[OK] ID:005_HW_CPU_BRAND | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:005_HW_CPU_BRAND | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 005_HW_CPU_BRAND : $($_.Exception.Message)" }
