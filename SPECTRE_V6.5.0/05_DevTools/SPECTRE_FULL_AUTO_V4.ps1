<#
.DESCRIPTION
    SPECTRE_FULL_AUTO_ENFORCER_V4
    - Phase 1 (Normal) : Préparation, copie C:\SPECTRE_TMP et armement BCD.
    - Phase 2 (Safe) : Reprise de possession automatique et injection forcée.
    - Confirmation interactive requise pour chaque bascule d'état.
#>

function Confirm-Action {
    param([string]$Message)
    Write-Host "`n[?] $Message" -ForegroundColor Yellow -NoNewline
    $Response = Read-Host " (Y/N)"
    return ($Response -eq "Y")
}

$LocalDir = "C:\SPECTRE_TMP"
$LocalScript = "$LocalDir\SPECTRE_FULL_AUTO_V4.ps1"
$BootState = (Get-WmiObject -Class Win32_ComputerSystem).BootupState

Write-Host "--- SPECTRE V4 : FULL-AUTO INTERACTIF ---" -ForegroundColor Cyan
Write-Host "[*] Environnement détecté : $BootState" -ForegroundColor White

# --- PHASE 1 : MODE NORMAL ---
if ($BootState -eq "Normal boot") {
    if (Confirm-Action "Armer le système pour une injection en Safe Mode (Copie locale + BCD) ?") {
        # 1. Création du miroir local
        if (!(Test-Path $LocalDir)) { New-Item -ItemType Directory -Path $LocalDir -Force | Out-Null }
        Copy-Item -Path $PSCommandPath -Destination $LocalScript -Force
        
        # 2. Armement du Safe Mode
        bcdedit /set "{current}" safeboot minimal
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Système armé. Prêt pour le reboot." -ForegroundColor Green
            if (Confirm-Action "Redémarrer en Mode Sans Échec maintenant ?") {
                shutdown /r /t 0 /f
            }
        } else {
            Write-Host "[!] ERREUR : BCDEDIT a échoué. Vérifiez vos privilèges Admin." -ForegroundColor Red
        }
    }
}

# --- PHASE 2 : MODE SANS ÉCHEC ---
elseif ($BootState -eq "Fail-safe boot") {
    Write-Host "[!] ALERTE : Mode Sans Échec actif. Début des injections forcées." -ForegroundColor Green

    if (Confirm-Action "Exécuter l'injection atomique (TamperProtection + Services) ?") {
        $RegPath = "SOFTWARE\Microsoft\Windows Defender\Features"
        
        try {
            Write-Host "[*] Tentative de reprise de possession de la ruche Defender..." -ForegroundColor Cyan
            # Prise de possession (Ownership)
            $Key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($RegPath, [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree, [System.Security.AccessControl.RegistryRights]::TakeOwnership)
            $Acl = $Key.GetAccessControl()
            $Acl.SetOwner([System.Security.Principal.NTAccount]"Administrateurs")
            $Key.SetAccessControl($Acl)
            
            # Attribution du Full Control
            $Acl = $Key.GetAccessControl()
            $Rule = New-Object System.Security.AccessControl.RegistryAccessRule("Administrateurs", "FullControl", "Allow")
            $Acl.SetAccessRule($Rule)
            $Key.SetAccessControl($Acl)
            
            # Écriture de la valeur
            reg add "HKLM\$RegPath" /v "TamperProtection" /t REG_DWORD /d 0 /f
            Write-Host "[SUCCESS] Tamper Protection neutralisée." -ForegroundColor Green

            # Désactivation des services (ID 310)
            @("WinDefend", "SecurityHealthService", "wscsvc").foreach({
                Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$_" -Name "Start" -Value 4 -Force
                Write-Host "[OK] Service $_ désactivé." -ForegroundColor Green
            })
        } catch {
            Write-Host "[!] ÉCHEC CRITIQUE : $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    if (Confirm-Action "Injections terminées. Restaurer le boot normal et redémarrer ?") {
        bcdedit /deletevalue "{current}" safeboot
        Write-Host "[OK] BCD restauré. Nettoyage final au prochain boot." -ForegroundColor Cyan
        shutdown /r /t 0 /f
    }
}