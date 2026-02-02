<# NOM : 028_SW_VMW_TOOLS_REG_Atom.ps1 | FAMILLE : 02_Software #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SOFTWARE\VMware, Inc.\VMware Tools" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SOFTWARE\VMware, Inc.\VMware Tools" -Name "InstallPath" -ErrorAction SilentlyContinue
        if ($null -eq $Val."InstallPath") {
            Write-Host "[!!] ID:028_SW_VMW_TOOLS_REG | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."InstallPath"
        if ("$Current" -eq "C:\Program Files\VMware\VMware Tools") { Write-Host "[OK] ID:028_SW_VMW_TOOLS_REG | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:028_SW_VMW_TOOLS_REG | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 028_SW_VMW_TOOLS_REG : $($_.Exception.Message)" }
