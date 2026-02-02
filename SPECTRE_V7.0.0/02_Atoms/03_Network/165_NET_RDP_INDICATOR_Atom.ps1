<# NOM : 165_NET_RDP_INDICATOR_Atom.ps1 | FAMILLE : 03_Network #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\System\CurrentControlSet\Control\Terminal Server" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -ErrorAction SilentlyContinue
        if ($null -eq $Val."fDenyTSConnections") {
            Write-Host "[!!] ID:165_NET_RDP_INDICATOR | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."fDenyTSConnections"
        if ("$Current" -eq "1") { Write-Host "[OK] ID:165_NET_RDP_INDICATOR | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:165_NET_RDP_INDICATOR | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 165_NET_RDP_INDICATOR : $($_.Exception.Message)" }
