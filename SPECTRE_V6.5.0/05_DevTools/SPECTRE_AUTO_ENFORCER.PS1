<#
.DESCRIPTION
    SPECTRE_AUTO_ENFORCER
    - Phase 1 : Armement du Safe Mode (bcdedit).
    - Phase 2 : Injection des Atomes 303 et 310 en Safe Mode.
    - Phase 3 : Restauration du Boot Normal.
#>

$BootState = (Get-WmiObject -Class Win32_ComputerSystem).BootupState
$LocalScript = "C:\Windows\Temp\SPECTRE_AUTO_ENFORCER.ps1"

Write-Host "--- SPECTRE : PROTOCOLE DE REBOOT AUTOMATISÉ ---" -ForegroundColor Cyan

# --- PHASE 1 : MODE NORMAL ---
if ($BootState -eq "Normal boot") {
    Write-Host "[*] Armement du Safe Mode et copie du script..." -ForegroundColor White
    Copy-Item -Path $PSCommandPath -Destination $LocalScript -Force
    
    # Inscription pour relance automatique en Safe Mode
    $RunOnceKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    Set-ItemProperty -Path $RunOnceKey -Name "SpectreEnforcer" -Value "powershell.exe -ExecutionPolicy Bypass -File $LocalScript"
    
    # Configuration du prochain boot en Safe Mode
    bcdedit /set "{current}" safeboot minimal
    
    Write-Host "[OK] Système prêt. Redémarrage dans 5 secondes..." -ForegroundColor Green
    Start-Sleep -Seconds 5
    Restart-Computer -Force
}

# --- PHASE 2 : MODE SANS ÉCHEC ---
elseif ($BootState -eq "Fail-safe boot") {
    Write-Host "[!] ALERTE : Mode Sans Échec détecté. Injection des Atomes..." -ForegroundColor Yellow
    
    # Injection directe des registres (Pas de résistance driver ici)
    reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtection" /t REG_DWORD /d 4 /f | Out-Null
    reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtectionSource" /t REG_DWORD /d 2 /f | Out-Null
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\WinDefend" /v "Start" /t REG_DWORD /d 4 /f | Out-Null
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\SecurityHealthService" /v "Start" /t REG_DWORD /d 4 /f | Out-Null
    
    Write-Host "[SUCCESS] Atomes injectés avec succès." -ForegroundColor Green
    
    # Nettoyage du Safe Mode pour le prochain boot
    bcdedit /deletevalue "{current}" safeboot
    
    Write-Host "[*] Retour en mode normal dans 5 secondes..." -ForegroundColor Cyan
    Start-Sleep -Seconds 5
    Restart-Computer -Force
}