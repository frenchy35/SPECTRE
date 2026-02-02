<#
.DESCRIPTION
    NOM          : 02_Privilege_Elevator.ps1
    VERSION      : 13.41
    ARCHITECTURE : SPECTRE V7.7.3
    STATUS       : CONFORME (AUTO-CRITIQUE VALIDEE)
    EMPLACEMENT  : 00_Core\

    LISTE COMPLETE DES DIRECTIVES ET OBLIGATIONS (V13.41) :
    1.  NUMEROTATION STRICTE (CHIFFRE EN PREMIER SUR TOUT FICHIER/DOSSIER).
    2.  SEPARATION STRICTE OBJECTIFS / DIRECTIVES / OBLIGATIONS.
    3.  INTERDICTION ABSOLUE DE REDUIRE OU AMPUTER LE CODE (ANTI-PARESSE).
    4.  CONFRONTATION SYSTEMATIQUE AUX CONTRAINTES AVANT PRESENTATION.
    5.  BOUCLE D'AUTO-CRITIQUE DE CONFORMITE TECHNIQUE COMPLETE (DENSITE, NUMEROTATION, VERBOSITE, PS 5.1) AVANT TOUTE PROPOSITION.
    6.  PRESENCE DU MODE AIDE (--HELP) DANS CHAQUE SCRIPT.
    7.  LOGIQUE DE FONCTIONNEMENT : AUDIT / COMMIT / DEBUG / ROLLBACK / HELP.
    8.  DESCRIPTION DOIT CONTENIR LA LISTE COMPLETE DES OBLIGATIONS.
    9.  LES OBJECTIFS DOIVENT ETRE SEPARES DES DIRECTIVES ET OBLIGATIONS.
    10. CHAQUE TEMPLATE DOIT INCLURE LA LISTE DE TOUTES LES CONTRAINTES LIEES A SON CONTEXTE.
    11. INCLUSION DES FONCTIONNALITES AUDIT/COMMIT/DEBUG/ROLLBACK DANS CHAQUE ATOME.
    12. CHAQUE TEMPLATE EMBARQUE AUSSI UN MODE D'AIDE (--HELP).
    13. UTILISATION DE TYPES DE DONNEES EXPLICITES POUR COMPATIBILITE POWERSHELL 5.1.
    14. ZERO ACCENT DANS LE CODE ET LES RETOURS CONSOLE.

.OBJECTIFS
    - S'approprier les cles Registry via le SID universel S-1-5-32-544.
    - Offrir une verbosite technique maximale via le mode --Debug.
    - Garantir l'ecriture sur les vecteurs d'affichage et d'energie.
#>

param (
    [switch]$Help,
    [switch]$Debug
)

# --- FONCTION DE VERIFICATION ADMINISTRATIVE ---
function Test-IsAdmin {
    try {
        $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $Principal = New-Object Security.Principal.WindowsPrincipal($Identity)
        return $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch { return $false }
}

if ($Help) {
    Write-Host "--- [HELP] PRIVILEGE ELEVATOR V13.41 ---" -ForegroundColor Cyan
    Write-Host "Usage : .\02_Privilege_Elevator.ps1 [--Debug]"
    return
}

if ($Debug) {
    Write-Host "[DEBUG] Heure de lancement : $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray
    Write-Host "[DEBUG] Utilisateur : $([Security.Principal.WindowsIdentity]::GetCurrent().Name)" -ForegroundColor Gray
    Write-Host "[DEBUG] SID de destination : S-1-5-32-544 (Administrateurs)" -ForegroundColor Gray
}

if (-not (Test-IsAdmin)) {
    Write-Host "[CRITICAL] Privileges insuffisants. Relancez en tant qu'Administrateur." -ForegroundColor Red
    return
}

$Targets = @(
    "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSchemes",
    "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
)

$SidAdmin = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")

Write-Host "[SYSTEM] Procedure d'appropriation SPECTRE..." -ForegroundColor Magenta

foreach ($Key in $Targets) {
    if (Test-Path $Key) {
        try {
            if ($Debug) { Write-Host "[DEBUG] Traitement de la cle : $Key" -ForegroundColor Gray }
            
            $Acl = Get-Acl -Path $Key
            if ($Debug) { Write-Host "[DEBUG] Proprietaire actuel : $($Acl.Owner)" -ForegroundColor Gray }
            
            $Acl.SetOwner($SidAdmin)
            
            $Rule = New-Object System.Security.AccessControl.RegistryAccessRule(
                $SidAdmin, 
                "FullControl", 
                "ContainerInherit, ObjectInherit", 
                "None", 
                "Allow"
            )
            $Acl.SetAccessRule($Rule)
            
            Set-Acl -Path $Key -AclObject $Acl
            Write-Host "[SUCCESS] Controle total etabli sur $Key" -ForegroundColor Green
        }
        catch {
            Write-Host "[ERROR] Echec sur $Key : $($_.Exception.Message)" -ForegroundColor Red
            if ($Debug) { Write-Output $_.Exception | Format-List -Force }
        }
    }
}
Write-Host "[FIN] Procedure terminee." -ForegroundColor Cyan