<#
.DESCRIPTION
    SPECTRE_V6_FULL_AUTO
    - Phase 1 : Armement Safe Mode + RunOnce (Normal Boot).
    - Phase 2 : Injection forcee avec regini.exe (Safe Mode).
    - Confirmations interactives pour chaque action et le reboot final.
#>

function Confirm-Action {
    param([string]$Message)
    Write-Host "`n[?] $Message" -ForegroundColor Yellow -NoNewline
    $Response = Read-Host " (Y/N)"
    return ($Response -eq "Y")
}

$LocalDir = "C:\SPECTRE_TMP"
$LocalScript = "$LocalDir\SPECTRE_V6_AUTO.ps1"
$BootState = (Get-WmiObject -Class Win32_ComputerSystem).BootupState

Write-Host "--- SPECTRE V6 : FULL-AUTO INTERACTIF ---" -ForegroundColor Cyan
Write-Host "[*] Environnement detecte : $BootState" -ForegroundColor White

# --- PHASE 1 : MODE NORMAL (ARMEMENT) ---
if ($BootState -eq "Normal boot") {
    if (Confirm-Action "Armer le Safe Mode et l'auto-execution au login ?") {
        if (!(Test-Path $LocalDir)) { New-Item -ItemType Directory -Path $LocalDir -Force | Out-Null }
        Copy-Item -Path $PSCommandPath -Destination $LocalScript -Force
        
        # Armement RunOnce pour execution auto au prochain login
        $Cmd = "powershell.exe -ExecutionPolicy Bypass -File `"$LocalScript`""
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name "SpectreV6" -Value $Cmd
        
        # Passage en Safe Mode
        bcdedit /set "{current}" safeboot minimal
        
        Write-Host "[OK] Systeme arme. Le script s'ouvrira seul en Safe Mode." -ForegroundColor Green
        if (Confirm-Action "Lancer le redemarrage en Safe Mode maintenant ?") { shutdown /r /t 0 /f }
    }
}

# --- PHASE 2 : MODE SANS ECHEC (INJECTION FORCEE) ---
elseif ($BootState -eq "Fail-safe boot") {
    Write-Host "[!] ALERTE : Mode Sans Echec detecte." -ForegroundColor Green

    if (Confirm-Action "Forcer la neutralisation (TakeOwnership + regini) ?") {
        $RegPath = "SOFTWARE\Microsoft\Windows Defender\Features"
        
        # Methode 1 : Reprise de possession .NET
        try {
            Write-Host "[*] Tentative de reprise de possession..." -ForegroundColor Cyan
            $Key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($RegPath, [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree, [System.Security.AccessControl.RegistryRights]::TakeOwnership)
            $Acl = $Key.GetAccessControl()
            $Acl.SetOwner([System.Security.Principal.NTAccount]"Administrateurs")
            $Key.SetAccessControl($Acl)
            
            $Acl = $Key.GetAccessControl()
            $Rule = New-Object System.Security.AccessControl.RegistryAccessRule("Administrateurs", "FullControl", "Allow")
            $Acl.SetAccessRule($Rule)
            $Key.SetAccessControl($Acl)
        } catch {
            Write-Host "[!] Echec .NET. Utilisation de REGINI (Brute Force)..." -ForegroundColor Yellow
            "HKEY_LOCAL_MACHINE\$RegPath [1 5 7 11 17]" | Out-File "$LocalDir\fix.txt" -Encoding ascii
            regini.exe "$LocalDir\fix.txt"
        }

        # Injection via REG.EXE
        reg add "HKLM\$RegPath" /v "TamperProtection" /t REG_DWORD /d 0 /f
        
        # Desactivation des services
        @("WinDefend", "SecurityHealthService", "wscsvc").foreach({
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$_" -Name "Start" -Value 4 -Force
        })
        Write-Host "[SUCCESS] Tamper Protection = 0 et Services neutralises." -ForegroundColor Green
    }

    Write-Host "`n[INFO] Pause de 5 secondes..." -ForegroundColor White
    Start-Sleep -Seconds 5

    if (Confirm-Action "Restaurer le Boot Normal et declencher le REBOOT FINAL ?") {
        bcdedit /deletevalue "{current}" safeboot
        $Cleanup = "cmd /c rd /s /q `"$LocalDir`""
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name "SpectreCleanup" -Value $Cleanup
        shutdown /r /t 0 /f
    }
}