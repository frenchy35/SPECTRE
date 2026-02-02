<# NOM : 130_SYS_KERNEL_PATCHGUARD_Atom.ps1 | FAMILLE : 06_System #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name "KernelVerifier" -ErrorAction SilentlyContinue
        if ($null -eq $Val."KernelVerifier") {
            Write-Host "[!!] ID:130_SYS_KERNEL_PATCHGUARD | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."KernelVerifier"
        if ("$Current" -eq "") { Write-Host "[OK] ID:130_SYS_KERNEL_PATCHGUARD | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:130_SYS_KERNEL_PATCHGUARD | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 130_SYS_KERNEL_PATCHGUARD : $($_.Exception.Message)" }
