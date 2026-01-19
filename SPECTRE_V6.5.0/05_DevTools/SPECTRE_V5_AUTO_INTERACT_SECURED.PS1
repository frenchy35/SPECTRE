<#
.DESCRIPTION
    SPECTRE_V5_AUTO_INTERACT_SECURED
    - Phase 1 (Normal) : Armement RunOnce + Safe Mode.
    - Phase 2 (Safe) : Exécution automatique au login.
    - Logique de TakeOwnership incluse.
    - Confirmation manuelle obligatoire AVANT le reboot final.
#>

function Confirm-Action {
    param([string]$Message)
    Write-Host "`n[?] $Message" -ForegroundColor Yellow -NoNewline
    $Response = Read-Host " (Y/N)"
    return ($Response -eq "Y")
}

$LocalDir = "C:\SPECTRE_TMP"
$LocalScript = "$LocalDir\SPECTRE_V5_AUTO.ps1"
$BootState = (Get-WmiObject -Class Win32_ComputerSystem).BootupState

Write-Host "--- SPECTRE V5.1 : AUTO-ENFORCER SECURISE ---" -ForegroundColor Cyan
Write-Host "[*] Environnement detecte : $BootState" -ForegroundColor White

# --- PHASE 1 : MODE NORMAL (ARMEMENT) ---
if ($BootState -eq "Normal boot") {
    if (Confirm-Action "Armer le Safe Mode et l'auto-execution au login ?") {
        # 1. Copie locale pour accessibilite en Safe Mode
        if (!(Test-Path $LocalDir)) { New-Item -ItemType Directory -Path $LocalDir -Force | Out-Null }
        Copy-Item -Path $PSCommandPath -Destination $LocalScript -Force
        
        # 2. Inscription RunOnce (Auto-supprimable par Windows après appel)
        $Cmd = "powershell.exe -ExecutionPolicy Bypass -File `"$LocalScript`""
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name "SpectreV5" -Value $Cmd
        
        # 3. Configuration du Safe Mode dans le BCD
        bcdedit /set "{current}" safeboot minimal
        
        Write-Host "[OK] Configuration terminee. Le script se lancera au login Safe Mode." -ForegroundColor Green
        if (Confirm-Action "Lancer le redemarrage maintenant ?") { shutdown /r /t 0 /f }
    }
}

# --- PHASE 2 : MODE SANS ÉCHEC (INJECTION & CONFIRMATION) ---
elseif ($BootState -eq "Fail-safe boot") {
    Write-Host "[!] ALERTE : Mode Sans Echec. Execution de l'Atome 303 (TamperProtection)." -ForegroundColor Green

    if (Confirm-Action "Executer la neutralisation forcee (ID 303 + Services) ?") {
        $RegPath = "SOFTWARE\Microsoft\Windows Defender\Features"
        
        try {
            Write-Host "[*] Tentative de reprise de possession (TakeOwnership)..." -ForegroundColor Cyan
            $Key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($RegPath, [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree, [System.Security.AccessControl.RegistryRights]::TakeOwnership)
            $Acl = $Key.GetAccessControl()
            $Acl.SetOwner([System.Security.Principal.NTAccount]"Administrateurs")
            $Key.SetAccessControl($Acl)
            
            $Acl = $Key.GetAccessControl()
            $Rule = New-Object System.Security.AccessControl.RegistryAccessRule("Administrateurs", "FullControl", "Allow")
            $Acl.SetAccessRule($Rule)
            $Key.SetAccessControl($Acl)
            
            reg add "HKLM\$RegPath" /v "TamperProtection" /t REG_DWORD /d 0 /f
            Write-Host "[SUCCESS] Tamper Protection mise a 0." -ForegroundColor Green
        } catch {
            Write-Host "[!] Blocage .NET. Passage par REGINI (Brute Force)..." -ForegroundColor Yellow
            "HKEY_LOCAL_MACHINE\$RegPath [1 5 7 11 17]" | Out-File "$LocalDir\fix.txt" -Encoding ascii
            regini.exe "$LocalDir\fix.txt"
            reg add "HKLM\$RegPath" /v "TamperProtection" /t REG_DWORD /d 0 /f
        }

        # Desactivation des services de defense
        @("WinDefend", "SecurityHealthService", "wscsvc").foreach({
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$_" -Name "Start" -Value 4 -Force
            Write-Host "[OK] Service $_ positionne sur Disabled." -ForegroundColor Green
        })
    }

    # Phase de sortie securisee
    Write-Host "`n[INFO] Injections terminees. Pause de 5 secondes pour lecture..." -ForegroundColor White
    Start-Sleep -Seconds 5

    if (Confirm-Action "Restaurer le Boot Normal et declencher le REBOOT FINAL ?") {
        # Nettoyage BCD
        bcdedit /deletevalue "{current}" safeboot
        
        # Nettoyage fichiers au prochain boot normal
        $Cleanup = "cmd /c rd /s /q `"$LocalDir`""
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name "SpectreCleanup" -Value $Cleanup
        
        Write-Host "[OK] Restauration validee. Sortie du Safe Mode." -ForegroundColor Cyan
        shutdown /r /t 0 /f
    } else {
        Write-Host "[!] Reboot annule. Vous devrez restaurer le BCD manuellement pour sortir." -ForegroundColor Red
    }
}