<#
.DESCRIPTION
    SPECTRE SAFE BOOT FORCE INJECTOR
    Execute uniquement les taches de durcissement bloquees par le noyau en mode normal.
    1. Neutralisation atomique de la Tamper Protection.
    2. Kill permanent des services de protection (WinDefend, SecurityHealth).
    3. Injection des exclusions de chemin et d'extension.
    4. Nettoyage des artifacts de comportement BCD.
#>

function Confirm-Action {
    param([string]$Message)
    Write-Host "`n[?] $Message" -ForegroundColor Yellow -NoNewline
    $Response = Read-Host " (Y/N)"
    return ($Response -eq "Y")
}

$BootState = (Get-WmiObject -Class Win32_ComputerSystem).BootupState
Write-Host "--- SPECTRE SAFE BOOT FORCE INJECTOR ---" -ForegroundColor Cyan
Write-Host "[*] Etat actuel du boot : $BootState" -ForegroundColor White

if ($BootState -ne "Fail-safe boot") {
    Write-Host "[!] ALERTE : Ce script doit etre execute en MODE SANS ECHEC." -ForegroundColor Red
    if (Confirm-Action "Voulez-vous configurer le Safe Mode et redemarrer ?") {
        bcdedit /set "{current}" safeboot minimal
        Restart-Computer -Force
    }
    exit
}

# --- DEBUT DES TACHES CRITIQUES (SAFE MODE UNIQUEMENT) ---
Write-Host "`n[!] MODE SANS ECHEC DETECTE. DEBUT DES INJECTIONS FORCÉES." -ForegroundColor Green

# 1. Neutralisation Tamper Protection (ID 303)
if (Confirm-Action "[ID 303] Forcer TamperProtection = 0 ?") {
    $TPPath = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features"
    Set-ItemProperty -Path $TPPath -Name "TamperProtection" -Value 0 -Force
    Write-Host "[OK] Tamper Protection neutralisee." -ForegroundColor Green
}

# 2. Desactivation des Services de Defense (ID 310, 311, 323)
if (Confirm-Action "[ID 310/311] Desactiver les services WinDefend et SecurityHealth ?") {
    $Services = @("WinDefend", "SecurityHealthService", "wscsvc", "Sense")
    foreach ($Svc in $Services) {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$Svc" -Name "Start" -Value 4 -Force
        Write-Host "[OK] Service $Svc positionne sur Disabled (Start=4)." -ForegroundColor Green
    }
}

# 3. Injection des Exclusions (ID 313, 314)
if (Confirm-Action "[ID 313/314] Injecter les exclusions de scan Defender ?") {
    $ExclPath = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths"
    if (!(Test-Path $ExclPath)) { New-Item -Path $ExclPath -Force | Out-Null }
    Set-ItemProperty -Path $ExclPath -Name "C:\" -Value 0 -Force
    Write-Host "[OK] Exclusion globale C:\ injectee." -ForegroundColor Green
}

# 4. Suppression des Telemetries de Boot (ID 201)
if (Confirm-Action "[ID 201] Desactiver la telemetrie de boot ELAM ?") {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\EarlyLaunch" -Name "DriverLoadPolicy" -Value 3 -Force
    Write-Host "[OK] Politique ELAM (Early Launch Antimalware) bridee." -ForegroundColor Green
}

# --- RESTAURATION ---
if (Confirm-Action "Taches terminees. Restaurer le boot NORMAL ?") {
    bcdedit /deletevalue "{current}" safeboot
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] BCD restaure." -ForegroundColor Green
        if (Confirm-Action "REDEMARRER en mode normal ?") {
            Restart-Computer -Force
        }
    }
}