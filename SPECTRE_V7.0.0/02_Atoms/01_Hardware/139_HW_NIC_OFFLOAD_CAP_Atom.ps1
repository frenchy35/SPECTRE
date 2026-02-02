<# NOM : 139_HW_NIC_OFFLOAD_CAP_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "DisableTaskOffload" -ErrorAction SilentlyContinue
        if ($null -eq $Val."DisableTaskOffload") {
            Write-Host "[!!] ID:139_HW_NIC_OFFLOAD_CAP | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."DisableTaskOffload"
        if ("$Current" -eq "0") { Write-Host "[OK] ID:139_HW_NIC_OFFLOAD_CAP | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:139_HW_NIC_OFFLOAD_CAP | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 139_HW_NIC_OFFLOAD_CAP : $($_.Exception.Message)" }
