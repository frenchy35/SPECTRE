<# NOM : 025_SW_VBOX_GUEST_Atom.ps1 | FAMILLE : 02_Software #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SOFTWARE\Oracle\VirtualBox Guest Additions" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Oracle\VirtualBox Guest Additions" -Name "Version" -ErrorAction SilentlyContinue
        if ($null -eq $Val."Version") {
            Write-Host "[!!] ID:025_SW_VBOX_GUEST | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."Version"
        if ("$Current" -eq "7.0.8") { Write-Host "[OK] ID:025_SW_VBOX_GUEST | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:025_SW_VBOX_GUEST | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 025_SW_VBOX_GUEST : $($_.Exception.Message)" }
