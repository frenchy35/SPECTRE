<# NOM : 196_NET_IPV6_SPOOF_Atom.ps1 | FAMILLE : 03_Network #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" -Name "RandomizeIdentifiers" -ErrorAction SilentlyContinue
        if ($null -eq $Val."RandomizeIdentifiers") {
            Write-Host "[!!] ID:196_NET_IPV6_SPOOF | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."RandomizeIdentifiers"
        if ("$Current" -eq "1") { Write-Host "[OK] ID:196_NET_IPV6_SPOOF | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:196_NET_IPV6_SPOOF | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 196_NET_IPV6_SPOOF : $($_.Exception.Message)" }
