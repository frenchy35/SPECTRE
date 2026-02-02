<# NOM : 015_HW_MAC_VBOX_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\0001" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\0001" -Name "NetworkAddress" -ErrorAction SilentlyContinue
        if ($null -eq $Val."NetworkAddress") {
            Write-Host "[!!] ID:015_HW_MAC_VBOX | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."NetworkAddress"
        if ("$Current" -eq "080027123456") { Write-Host "[OK] ID:015_HW_MAC_VBOX | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:015_HW_MAC_VBOX | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 015_HW_MAC_VBOX : $($_.Exception.Message)" }
