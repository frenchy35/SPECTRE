<# NOM : 072_NET_DNS_VM_DOMAIN_Atom.ps1 | FAMILLE : 03_Network #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "SearchList" -ErrorAction SilentlyContinue
        if ($null -eq $Val."SearchList") {
            Write-Host "[!!] ID:072_NET_DNS_VM_DOMAIN | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."SearchList"
        if ("$Current" -eq "") { Write-Host "[OK] ID:072_NET_DNS_VM_DOMAIN | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:072_NET_DNS_VM_DOMAIN | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 072_NET_DNS_VM_DOMAIN : $($_.Exception.Message)" }
