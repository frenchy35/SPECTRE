<# NOM : 123_NET_ADAPTER_VM_NAME_Atom.ps1 | FAMILLE : 03_Network #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Control\Network\*" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Network\*" -Name "Name" -ErrorAction SilentlyContinue
        if ($null -eq $Val."Name") {
            Write-Host "[!!] ID:123_NET_ADAPTER_VM_NAME | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."Name"
        if ("$Current" -eq "Local Area Connection") { Write-Host "[OK] ID:123_NET_ADAPTER_VM_NAME | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:123_NET_ADAPTER_VM_NAME | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 123_NET_ADAPTER_VM_NAME : $($_.Exception.Message)" }
