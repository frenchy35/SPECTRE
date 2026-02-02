<# NOM : 100_SW_VBOX_TRAY_RUN_Atom.ps1 | FAMILLE : 02_Software #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "VBoxTray" -ErrorAction SilentlyContinue
        if ($null -eq $Val."VBoxTray") {
            Write-Host "[!!] ID:100_SW_VBOX_TRAY_RUN | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."VBoxTray"
        if ("$Current" -eq "") { Write-Host "[OK] ID:100_SW_VBOX_TRAY_RUN | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:100_SW_VBOX_TRAY_RUN | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 100_SW_VBOX_TRAY_RUN : $($_.Exception.Message)" }
