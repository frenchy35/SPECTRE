<# NOM : 045_BEHAV_CORES_FIX_Atom.ps1 | FAMILLE : 04_Behavior #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" -Name "NUMBER_OF_PROCESSORS" -ErrorAction SilentlyContinue
        if ($null -eq $Val."NUMBER_OF_PROCESSORS") {
            Write-Host "[!!] ID:045_BEHAV_CORES_FIX | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."NUMBER_OF_PROCESSORS"
        if ("$Current" -eq "8") { Write-Host "[OK] ID:045_BEHAV_CORES_FIX | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:045_BEHAV_CORES_FIX | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 045_BEHAV_CORES_FIX : $($_.Exception.Message)" }
