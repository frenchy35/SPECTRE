<# NOM : 153_HW_UEFI_VARIABLE_VBOX_Atom.ps1 | FAMILLE : 01_Hardware #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\State" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\State" -Name "UEFIVariables" -ErrorAction SilentlyContinue
        if ($null -eq $Val."UEFIVariables") {
            Write-Host "[!!] ID:153_HW_UEFI_VARIABLE_VBOX | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."UEFIVariables"
        if ("$Current" -eq "") { Write-Host "[OK] ID:153_HW_UEFI_VARIABLE_VBOX | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:153_HW_UEFI_VARIABLE_VBOX | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 153_HW_UEFI_VARIABLE_VBOX : $($_.Exception.Message)" }
