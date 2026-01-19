<#
.DESCRIPTION
    SPECTRE FORENSIC AUDITOR - V7.1
    Version : V7.1 (Fix SubExpression Syntax)
    NB LIGNES : 140
#>

[CmdletBinding()]
param()

Clear-Host
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "      SPECTRE V6.5.0 | FORENSIC AUDIT TOOL | 2026-01-16" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

$Results = @()

function Test-Artifact {
    param($Category, $Point, $Command, $ExpectedValue)
    
    Write-Host "[*] Testing $Point... " -NoNewline -ForegroundColor Gray
    try {
        $Current = Invoke-Expression $Command
        $Status = if ($Current -match [regex]::Escape($ExpectedValue)) { "PASS" } else { "FAIL" }
        $Color = if ($Status -eq "PASS") { "Green" } else { "Red" }
        
        Write-Host "$Status" -ForegroundColor $Color
        return [PSCustomObject]@{
            Category = $Category
            Artifact = $Point
            Expected = $ExpectedValue
            Current  = $Current
            Status   = $Status
        }
    } catch {
        Write-Host "ERROR" -ForegroundColor Yellow
        return $null
    }
}

# --- SEGMENT 1 : SILICON IDENTITY ---
Write-Host "`n[1] SEGMENT : SILICON IDENTITY" -ForegroundColor Cyan
$Results += Test-Artifact "Silicon" "CPU Name" "(Get-CimInstance Win32_Processor).Name" "i9-12900K"
$Results += Test-Artifact "Silicon" "GPU Name" "(Get-CimInstance Win32_VideoController).Name" "RTX 3080"
$Results += Test-Artifact "Silicon" "BIOS Vendor" "(Get-CimInstance Win32_BIOS).Manufacturer" "American Megatrends"
$Results += Test-Artifact "Silicon" "MB Product" "(Get-CimInstance Win32_BaseBoard).Product" "Z690-E"

# --- SEGMENT 2 : VIRTUALIZATION LEAKS ---
Write-Host "`n[2] SEGMENT : VIRTUALIZATION LEAKS" -ForegroundColor Cyan
$VMCheck = Get-Service -Name "*VMTools*" -ErrorAction SilentlyContinue
$StatusVM = if ($null -eq $VMCheck) { "PASS" } else { "FAIL" }
$ColorVM = if ($StatusVM -eq "PASS") { "Green" } else { "Red" }
Write-Host "[*] Testing VMTools Absence... $StatusVM" -ForegroundColor $ColorVM

$Results += [PSCustomObject]@{
    Category = "Anti-VM"
    Artifact = "VMware Services"
    Expected = "None"
    Current  = if ($null -eq $VMCheck) { "Clean" } else { "Found" }
    Status   = $StatusVM
}

# --- SEGMENT 3 : NETWORK STACK ---
Write-Host "`n[3] SEGMENT : NETWORK STACK" -ForegroundColor Cyan
$IPv6 = (Get-NetAdapterBinding -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue | Where-Object {$_.ComponentID -eq "ms_tcpip6"}).Enabled
$Results += Test-Artifact "Network" "IPv6 Enabled" "return '$IPv6'" "False"
# TTL Check via Ping local loopback pour voir le TTL reel sortant
$TTL = (ping -n 1 127.0.0.1 | Select-String "TTL=").ToString()
$Results += Test-Artifact "Network" "TCP TTL" "return '$TTL'" "TTL=64"

# --- SEGMENT 4 : DEFENSE STATE ---
Write-Host "`n[4] SEGMENT : DEFENSE STATE" -ForegroundColor Cyan
$DefSvc = Get-Service -Name "WinDefend" -ErrorAction SilentlyContinue
$Results += [PSCustomObject]@{
    Category = "Defense"
    Artifact = "WinDefend Service"
    Expected = "Stopped"
    Current  = if ($null -ne $DefSvc) { $DefSvc.Status } else { "Not Found" }
    Status   = if ($null -eq $DefSvc -or $DefSvc.Status -eq "Stopped") { "PASS" } else { "FAIL" }
}

# --- SYNTHESE FINALE ---
Write-Host "`n" + ("="*80) -ForegroundColor Cyan
Write-Host "                           SYNTHESE FORENSIQUE" -ForegroundColor Cyan
Write-Host ("="*80) + "`n" -ForegroundColor Cyan

$Results | Format-Table -AutoSize

$PassCount = ($Results | Where-Object { $_.Status -eq "PASS" }).Count
$Score = [math]::Round(($PassCount / $Results.Count) * 100, 2)
$FinalColor = if ($Score -gt 90) { "Green" } else { "Yellow" }

Write-Host "`n[RESULTAT] Score de credibilite physique : $Score %" -ForegroundColor $FinalColor
Write-Host "`n"