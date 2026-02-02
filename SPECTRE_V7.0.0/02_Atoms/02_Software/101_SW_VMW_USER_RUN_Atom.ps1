<# NOM : 101_SW_VMW_USER_RUN_Atom.ps1 | FAMILLE : 02_Software #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "VMware User Process" -ErrorAction SilentlyContinue
        if ($null -eq $Val."VMware User Process") {
            Write-Host "[!!] ID:101_SW_VMW_USER_RUN | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."VMware User Process"
        if ("$Current" -eq "") { Write-Host "[OK] ID:101_SW_VMW_USER_RUN | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:101_SW_VMW_USER_RUN | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 101_SW_VMW_USER_RUN : $($_.Exception.Message)" }
