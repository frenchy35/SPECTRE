<#
.DESCRIPTION
    NOM : Spectre_Core_Logic.psm1 | VERSION : 6.9 (CORE COMPAT)
    DESCRIPTION : Intelligence centrale compatible PS 5.1 et 7+.
#>

function Out-Spectre {
    param([string]$M, [string]$L="INFO", [string]$ID="CORE")
    $T = Get-Date -Format "HH:mm:ss"
    $C = "Gray"
    if ($L -eq "SUCCESS") { $C = "Green" }
    elseif ($L -eq "ERR") { $C = "Red" }
    elseif ($L -eq "DEBUG") { $C = "Cyan" }
    elseif ($L -eq "WARN") { $C = "Yellow" }
    Write-Host "[$T][$L][$ID] $M" -ForegroundColor $C
}

function Invoke-SpectreAudit {
    param($Targets, $TechID)
    Out-Spectre "Lancement de l'audit matriciel..." "DEBUG" $TechID
    $Report = @()
    $SuccessCount = 0

    foreach ($T in $Targets) {
        $Row = [PSCustomObject]@{ Cible = ""; Status = "KO"; Detail = "" }
        if ($T.T -eq "Registry") {
            $Row.Cible = $T.Key
            $Val = (Get-ItemProperty -Path $T.Path -Name $T.Key -ErrorAction SilentlyContinue).$($T.Key)
            if ($null -ne $Val -and $Val.ToString() -eq $T.Value.ToString()) {
                $Row.Status = "OK"; $Row.Detail = "Conforme"; $SuccessCount++
            } else {
                $Actual = if ($null -eq $Val) { "ABSENT" } else { $Val }
                $Row.Detail = "Ecart (Attendu: $($T.Value) | Trouve: $Actual)"
            }
        } 
        elseif ($T.T -eq "Service") {
            $Row.Cible = $T.Target
            $Svc = Get-Service -Name $T.Target -ErrorAction SilentlyContinue
            if ($null -ne $Svc -and $Svc.Status -eq "Stopped") {
                $Row.Status = "OK"; $Row.Detail = "Service Stoppe"; $SuccessCount++
            } else {
                $Row.Detail = "Service actif ou manquant"
            }
        }
        $Report += $Row
    }
    $Report | Format-Table -AutoSize
    $Percent = [math]::Round(($SuccessCount / $Targets.Count) * 100)
    Out-Spectre "Verdict : $Percent% conformite ($SuccessCount / $($Targets.Count) cibles)." "SUCCESS" $TechID
    return $Report
}

function Invoke-SpectreCommit {
    param($Targets, $TechID)
    Out-Spectre "ALIGNEMENT DES CIBLES (COMMIT)..." "WARN" $TechID
    foreach ($T in $Targets) {
        try {
            if ($T.T -eq "Registry") {
                if (-not (Test-Path $T.Path)) { New-Item -Path $T.Path -Force | Out-Null }
                Set-ItemProperty -Path $T.Path -Name $T.Key -Value $T.Value -Force -ErrorAction Stop
                Out-Spectre "Cible [REG] $($T.Key) : Aligne" "DEBUG" $TechID
            }
            elseif ($T.T -eq "Service") {
                Stop-Service -Name $T.Target -Force -ErrorAction SilentlyContinue
                Out-Spectre "Cible [SVC] $($T.Target) : Stoppe" "DEBUG" $TechID
            }
        } catch {
            $errName = if ($T.Key) { $T.Key } else { $T.Target }
            Out-Spectre "Echec sur $errName : $($_.Exception.Message)" "ERR" $TechID
        }
    }
}

function Invoke-SpectreRollback {
    param($Targets, $TechID)
    Out-Spectre "RESTAURATION DE L'ETAT (ROLLBACK)..." "WARN" $TechID
    foreach ($T in $Targets) {
        if ($T.T -eq "Registry") {
            Remove-ItemProperty -Path $T.Path -Name $T.Key -ErrorAction SilentlyContinue
            Out-Spectre "Cible [REG] $($T.Key) : Restaure (Supprime)" "DEBUG" $TechID
        }
        elseif ($T.T -eq "Service") {
            Start-Service -Name $T.Target -ErrorAction SilentlyContinue
            Out-Spectre "Cible [SVC] $($T.Target) : Redemarre" "DEBUG" $TechID
        }
    }
}

Export-ModuleMember -Function Invoke-SpectreAudit, Invoke-SpectreCommit, Invoke-SpectreRollback, Out-Spectre