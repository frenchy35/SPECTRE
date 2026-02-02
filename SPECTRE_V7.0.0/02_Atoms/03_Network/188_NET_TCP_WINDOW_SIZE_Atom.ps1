<# NOM : 188_NET_TCP_WINDOW_SIZE_Atom.ps1 | FAMILLE : 03_Network #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpWindowSize" -ErrorAction SilentlyContinue
        if ($null -eq $Val."TcpWindowSize") {
            Write-Host "[!!] ID:188_NET_TCP_WINDOW_SIZE | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."TcpWindowSize"
        if ("$Current" -eq "64240") { Write-Host "[OK] ID:188_NET_TCP_WINDOW_SIZE | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:188_NET_TCP_WINDOW_SIZE | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 188_NET_TCP_WINDOW_SIZE : $($_.Exception.Message)" }
