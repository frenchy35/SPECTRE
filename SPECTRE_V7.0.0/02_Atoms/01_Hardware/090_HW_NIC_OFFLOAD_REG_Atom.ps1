<# NOM : 090_HW_NIC_OFFLOAD_REG_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "DisableTaskOffload" -ErrorAction SilentlyContinue
        if ($null -eq $Val."DisableTaskOffload") {
            Write-Host "[!!] ID:090_HW_NIC_OFFLOAD_REG | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."DisableTaskOffload"
        if ("$Current" -eq "0") { Write-Host "[OK] ID:090_HW_NIC_OFFLOAD_REG | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:090_HW_NIC_OFFLOAD_REG | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 090_HW_NIC_OFFLOAD_REG : $($_.Exception.Message)" }
