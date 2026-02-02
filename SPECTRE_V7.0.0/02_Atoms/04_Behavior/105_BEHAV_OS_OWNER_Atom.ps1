<# NOM : 105_BEHAV_OS_OWNER_Atom.ps1 | FAMILLE : 04_Behavior #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "RegisteredOwner" -ErrorAction SilentlyContinue
        if ($null -eq $Val."RegisteredOwner") {
            Write-Host "[!!] ID:105_BEHAV_OS_OWNER | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."RegisteredOwner"
        if ("$Current" -eq "Spectre_Operator") { Write-Host "[OK] ID:105_BEHAV_OS_OWNER | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:105_BEHAV_OS_OWNER | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 105_BEHAV_OS_OWNER : $($_.Exception.Message)" }
