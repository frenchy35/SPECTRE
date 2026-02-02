<# NOM : 075_BEHAV_OS_INSTALL_DATE_Atom.ps1 | FAMILLE : 04_Behavior #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "InstallDate" -ErrorAction SilentlyContinue
        if ($null -eq $Val."InstallDate") {
            Write-Host "[!!] ID:075_BEHAV_OS_INSTALL_DATE | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."InstallDate"
        if ("$Current" -eq "1672531200") { Write-Host "[OK] ID:075_BEHAV_OS_INSTALL_DATE | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:075_BEHAV_OS_INSTALL_DATE | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 075_BEHAV_OS_INSTALL_DATE : $($_.Exception.Message)" }
