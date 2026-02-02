<# NOM : 006_HW_DISK_NAME_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\Enum\IDE\Disk*" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\Enum\IDE\Disk*" -Name "FriendlyName" -ErrorAction SilentlyContinue
        if ($null -eq $Val."FriendlyName") {
            Write-Host "[!!] ID:006_HW_DISK_NAME | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."FriendlyName"
        if ("$Current" -eq "ST500DM002") { Write-Host "[OK] ID:006_HW_DISK_NAME | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:006_HW_DISK_NAME | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 006_HW_DISK_NAME : $($_.Exception.Message)" }
