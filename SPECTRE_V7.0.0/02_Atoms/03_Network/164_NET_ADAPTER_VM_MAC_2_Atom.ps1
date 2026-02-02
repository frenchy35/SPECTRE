<# NOM : 164_NET_ADAPTER_VM_MAC_2_Atom.ps1 | FAMILLE : 03_Network #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\0003" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\0003" -Name "NetworkAddress" -ErrorAction SilentlyContinue
        if ($null -eq $Val."NetworkAddress") {
            Write-Host "[!!] ID:164_NET_ADAPTER_VM_MAC_2 | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."NetworkAddress"
        if ("$Current" -eq "00155D010203") { Write-Host "[OK] ID:164_NET_ADAPTER_VM_MAC_2 | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:164_NET_ADAPTER_VM_MAC_2 | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 164_NET_ADAPTER_VM_MAC_2 : $($_.Exception.Message)" }
