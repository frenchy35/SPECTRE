<# NOM : 167_BEHAV_WMI_VBOX_ENCLOSURE_Atom.ps1 | FAMILLE : 04_Behavior #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\HARDWARE\Description\System" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\HARDWARE\Description\System" -Name "EnclosureType" -ErrorAction SilentlyContinue
        if ($null -eq $Val."EnclosureType") {
            Write-Host "[!!] ID:167_BEHAV_WMI_VBOX_ENCLOSURE | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."EnclosureType"
        if ("$Current" -eq "3") { Write-Host "[OK] ID:167_BEHAV_WMI_VBOX_ENCLOSURE | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:167_BEHAV_WMI_VBOX_ENCLOSURE | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 167_BEHAV_WMI_VBOX_ENCLOSURE : $($_.Exception.Message)" }
