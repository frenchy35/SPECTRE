<#
.DESCRIPTION
    SPECTRE SAFE BOOT ORCHESTRATOR V2
    Utilise WMI pour la detection du mode de boot (evite l'erreur TypeNotFound).
    Demande confirmation a chaque etape critique.
#>

function Confirm-Action {
    param([string]$Message)
    Write-Host "`n[?] $Message" -ForegroundColor Yellow -NoNewline
    $Response = Read-Host " (Y/N)"
    return ($Response -eq "Y")
}

# Detection du mode de boot via WMI
# "Normal boot" ou "Fail-safe boot"
$BootState = (Get-WmiObject -Class Win32_ComputerSystem).BootupState

Write-Host "--- SPECTRE BOOT ORCHESTRATOR V2 ---" -ForegroundColor Cyan
Write-Host "[*] Etat actuel du boot : $BootState" -ForegroundColor White

# --- PHASE 1 : DEPUIS LE MODE NORMAL ---
if ($BootState -eq "Normal boot") {
    if (Confirm-Action "Voulez-vous configurer le prochain boot en MODE SANS ECHEC ?") {
        # Modification du BCD
        bcdedit /set {current} safeboot minimal
        Write-Host "[OK] BCD mis a jour pour Safe Mode." -ForegroundColor Green
        
        if (Confirm-Action "REDEMARRER la machine maintenant ?") {
            Restart-Computer -Force
        }
    }
}

# --- PHASE 2 : DEPUIS LE MODE SANS ECHEC ---
elseif ($BootState -eq "Fail-safe boot") {
    Write-Host "[!] ALERTE : Mode Sans Echec detecte (Drivers de filtrage inactifs)." -ForegroundColor Green
    
    if (Confirm-Action "Forcer la neutralisation de la Tamper Protection (ID 303) ?") {
        $TPPath = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features"
        Set-ItemProperty -Path $TPPath -Name "TamperProtection" -Value 0 -Force
        Write-Host "[OK] Registre modifie avec succes." -ForegroundColor Green
    }

    if (Confirm-Action "Executer l'orchestrateur Master_Enforcer (149 derives) ?") {
        & "G:\Mon Drive\PROJETS\EN_COURS\SPECTRE\SPECTRE_V6.5.0\03_Orchestrators\Master_Enforcer.ps1"
    }

    if (Confirm-Action "RESTAURER le mode de boot normal ?") {
        bcdedit /deletevalue {current} safeboot
        Write-Host "[OK] BCD restaure." -ForegroundColor Green
        
        if (Confirm-Action "REDEMARRER en mode normal maintenant ?") {
            Restart-Computer -Force
        }
    }
}

else {
    Write-Host "[!] Etat de boot inconnu ($BootState). Operation interrompue." -ForegroundColor Red
}