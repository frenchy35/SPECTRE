<#
.DESCRIPTION
    SPECTRE TAMPER CHECK
    Audit profond de l'etat de la Protection contre les alterations.
    Perspective : Ingenieur Cybersecurite.
#>

$TamperKey = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features"
$Result = @{ "Status" = "Unknown"; "Value" = $null }

Write-Host "[*] Audit de la Tamper Protection..." -ForegroundColor Cyan

try {
    # On tente de lire la valeur 'TamperProtection'
    # 0 = OFF (Cible SPECTRE)
    # 1/3/4/5 = ON (Verrouille par le Kernel)
    $TPValue = Get-ItemProperty -Path $TamperKey -Name "TamperProtection" -ErrorAction Stop
    $Result.Value = $TPValue.TamperProtection
    
    if ($Result.Value -eq 0) {
        $Result.Status = "OFF (UNLOCKED)"
        Write-Host "[OK] Tamper Protection : $($Result.Status)" -ForegroundColor Green
    } else {
        $Result.Status = "ON (LOCKED - Value: $($Result.Value))"
        Write-Host "[!] Tamper Protection : $($Result.Status)" -ForegroundColor Red
    }
} catch {
    # Si on ne peut meme pas lire la cle, c'est que le driver de filtrage bloque l'acces
    Write-Host "[!] ECHEC CRITIQUE : Acces refuse a la ruche Defender. Le verrou est actif au niveau Kernel." -ForegroundColor Red
    $Result.Status = "HARD-LOCKED"
}

# Verification subsidiaire : Service WinDefend
$Service = Get-Service -Name "WinDefend"
Write-Host "[*] Etat du service WinDefend : $($Service.Status)" -ForegroundColor Cyan

if ($Result.Value -ne 0 -and $Service.Status -eq "Running") {
    Write-Host "[!] Diagnostic : La protection bloque toute tentative d'injection d'artifacts de comportement." -ForegroundColor Yellow
}

return $Result