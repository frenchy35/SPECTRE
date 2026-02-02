<# NOM : 144_BEHAV_USER_ENV_VAR_Atom.ps1 | FAMILLE : 04_Behavior #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKCU:\Environment" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKCU:\Environment" -Name "PROJECT_ROOT" -ErrorAction SilentlyContinue
        if ($null -eq $Val."PROJECT_ROOT") {
            Write-Host "[!!] ID:144_BEHAV_USER_ENV_VAR | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."PROJECT_ROOT"
        if ("$Current" -eq "C:\Work\Spectre") { Write-Host "[OK] ID:144_BEHAV_USER_ENV_VAR | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:144_BEHAV_USER_ENV_VAR | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 144_BEHAV_USER_ENV_VAR : $($_.Exception.Message)" }
