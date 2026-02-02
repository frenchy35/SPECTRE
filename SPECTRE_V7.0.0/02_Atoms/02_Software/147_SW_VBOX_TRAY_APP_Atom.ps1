<# NOM : 147_SW_VBOX_TRAY_APP_Atom.ps1 | FAMILLE : 02_Software #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "VBoxTray" -ErrorAction SilentlyContinue
        if ($null -eq $Val."VBoxTray") {
            Write-Host "[!!] ID:147_SW_VBOX_TRAY_APP | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."VBoxTray"
        if ("$Current" -eq "") { Write-Host "[OK] ID:147_SW_VBOX_TRAY_APP | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:147_SW_VBOX_TRAY_APP | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 147_SW_VBOX_TRAY_APP : $($_.Exception.Message)" }
