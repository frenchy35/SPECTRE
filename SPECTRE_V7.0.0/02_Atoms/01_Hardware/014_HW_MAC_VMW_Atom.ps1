<# NOM : 014_HW_MAC_VMW_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\0002" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\0002" -Name "NetworkAddress" -ErrorAction SilentlyContinue
        if ($null -eq $Val."NetworkAddress") {
            Write-Host "[!!] ID:014_HW_MAC_VMW | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."NetworkAddress"
        if ("$Current" -eq "005056C00001") { Write-Host "[OK] ID:014_HW_MAC_VMW | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:014_HW_MAC_VMW | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 014_HW_MAC_VMW : $($_.Exception.Message)" }
