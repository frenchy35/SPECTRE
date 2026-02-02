<# NOM : 183_BEHAV_WMI_VBOX_SYS_Atom.ps1 | FAMILLE : 04_Behavior #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\HARDWARE\Description\System" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\HARDWARE\Description\System" -Name "SystemFamily" -ErrorAction SilentlyContinue
        if ($null -eq $Val."SystemFamily") {
            Write-Host "[!!] ID:183_BEHAV_WMI_VBOX_SYS | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."SystemFamily"
        if ("$Current" -eq "Laptop") { Write-Host "[OK] ID:183_BEHAV_WMI_VBOX_SYS | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:183_BEHAV_WMI_VBOX_SYS | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 183_BEHAV_WMI_VBOX_SYS : $($_.Exception.Message)" }
