<# NOM : 044_BEHAV_RES_FIX_Atom.ps1 | FAMILLE : 04_Behavior #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Control\Video\*" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Video\*" -Name "DefaultSettings.XResolution" -ErrorAction SilentlyContinue
        if ($null -eq $Val."DefaultSettings.XResolution") {
            Write-Host "[!!] ID:044_BEHAV_RES_FIX | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."DefaultSettings.XResolution"
        if ("$Current" -eq "1920") { Write-Host "[OK] ID:044_BEHAV_RES_FIX | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:044_BEHAV_RES_FIX | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 044_BEHAV_RES_FIX : $($_.Exception.Message)" }
