<# NOM : 070_NET_VBOX_HOST_ONLY_Atom.ps1 | FAMILLE : 03_Network #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Control\Network\{4D36E972-E325-11CE-BFC1-08002BE10318}\*\Connection" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Network\{4D36E972-E325-11CE-BFC1-08002BE10318}\*\Connection" -Name "Name" -ErrorAction SilentlyContinue
        if ($null -eq $Val."Name") {
            Write-Host "[!!] ID:070_NET_VBOX_HOST_ONLY | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."Name"
        if ("$Current" -eq "Ethernet") { Write-Host "[OK] ID:070_NET_VBOX_HOST_ONLY | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:070_NET_VBOX_HOST_ONLY | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 070_NET_VBOX_HOST_ONLY : $($_.Exception.Message)" }
