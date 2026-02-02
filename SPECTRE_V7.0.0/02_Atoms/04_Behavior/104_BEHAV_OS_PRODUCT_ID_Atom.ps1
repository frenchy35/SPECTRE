<# NOM : 104_BEHAV_OS_PRODUCT_ID_Atom.ps1 | FAMILLE : 04_Behavior #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ProductId" -ErrorAction SilentlyContinue
        if ($null -eq $Val."ProductId") {
            Write-Host "[!!] ID:104_BEHAV_OS_PRODUCT_ID | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."ProductId"
        if ("$Current" -eq "00330-80000-00000-AA999") { Write-Host "[OK] ID:104_BEHAV_OS_PRODUCT_ID | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:104_BEHAV_OS_PRODUCT_ID | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 104_BEHAV_OS_PRODUCT_ID : $($_.Exception.Message)" }
