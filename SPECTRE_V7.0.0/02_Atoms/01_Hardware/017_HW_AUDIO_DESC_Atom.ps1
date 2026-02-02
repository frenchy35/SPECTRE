<# NOM : 017_HW_AUDIO_DESC_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e96c-e325-11ce-bfc1-08002be10318}\0000" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e96c-e325-11ce-bfc1-08002be10318}\0000" -Name "DriverDesc" -ErrorAction SilentlyContinue
        if ($null -eq $Val."DriverDesc") {
            Write-Host "[!!] ID:017_HW_AUDIO_DESC | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."DriverDesc"
        if ("$Current" -eq "Realtek High Definition Audio") { Write-Host "[OK] ID:017_HW_AUDIO_DESC | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:017_HW_AUDIO_DESC | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 017_HW_AUDIO_DESC : $($_.Exception.Message)" }
