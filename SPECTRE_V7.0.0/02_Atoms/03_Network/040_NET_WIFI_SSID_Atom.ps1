<# NOM : 040_NET_WIFI_SSID_Atom.ps1 | FAMILLE : 03_Network #>
param ([string]$Mode="Audit",[switch]$Debug)
try {
    if ($Mode -eq "Audit") {
        if ($Debug) { Write-Host "[DEBUG] Path: HKLM:\SOFTWARE\Microsoft\WlanSvc\*" -ForegroundColor Gray }
        $Val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WlanSvc\*" -Name "ProfileName" -ErrorAction SilentlyContinue
        if ($null -eq $Val."ProfileName") {
            Write-Host "[!!] ID:040_NET_WIFI_SSID | STATUS:ABSENT" -ForegroundColor Yellow ; return
        }
        $Current = [string]$Val."ProfileName"
        if ("$Current" -eq "Office_Secure_WiFi") { Write-Host "[OK] ID:040_NET_WIFI_SSID | STATUS:FURTIF" }
        else { Write-Host "[!!] ID:040_NET_WIFI_SSID | STATUS:DETECTE | VAL:$Current" }
    }
} catch { Write-Host "[ERR] 040_NET_WIFI_SSID : $($_.Exception.Message)" }
