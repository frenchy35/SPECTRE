<# NOM : 021_HW_VIDEO_DESC_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" -Name "DriverDesc" -ErrorAction SilentlyContinue
        if ($null -eq $Val."DriverDesc") {
            Write-Host "[!!] ID:021_HW_VIDEO_DESC | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."DriverDesc"
        if ("$Current" -eq "NVIDIA GeForce RTX 4070") { Write-Host "[OK] ID:021_HW_VIDEO_DESC | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:021_HW_VIDEO_DESC | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 021_HW_VIDEO_DESC : $($_.Exception.Message)" }
