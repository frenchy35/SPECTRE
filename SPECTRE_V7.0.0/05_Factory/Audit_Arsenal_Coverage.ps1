<#
.DESCRIPTION
    NOM : Audit_Arsenal_Coverage.ps1
    VERSION : 7.8.5
    --- OBLIGATIONS ET CONTRAINTES ---
    1. VERBOSITE TOTALE : Rapport détaillé par catégorie tactique.
    2. ZERO INVENTION : Analyse stricte du contenu JSON.
    3. CODES COULEURS : Cyan (Info), Jaune (Manquant), Vert (Opérationnel).
    4. SCRIPT COMPLET : Autonome.
#>

function Out-Spectre {
    param([string]$M, [string]$L="INFO")
    $T = Get-Date -Format "HH:mm:ss.fff"
    $C = switch($L) { "ERR"{"Red"} "WARN"{"Yellow"} "SUCCESS"{"Green"} "DEBUG"{"Cyan"} Default{"Gray"} }
    Write-Host "[$T][$L][AUDIT] $M" -ForegroundColor $C
}

$ProjectRoot = "C:\Users\LGE\Mon Drive\PROJETS\EN_COURS\SPECTRE\SPECTRE_V7.0.0"
$MasterDBPath = Join-Path $ProjectRoot "00_Core\MITRE_Master_DB.json"

Out-Spectre "Lancement de l'audit de couverture SPECTRE..." "DEBUG"

if (-not (Test-Path $MasterDBPath)) {
    Out-Spectre "ERREUR : Master DB introuvable." "ERR" ; return
}

$DB = Get-Content $MasterDBPath -Raw | ConvertFrom-Json
$Techs = $DB.Techniques.PSObject.Properties

$GlobalTotal = 0
$ReadyCount = 0
$EmptyCount = 0
$StatsByTactic = @{}

foreach ($Prop in $Techs) {
    $T = $Prop.Value
    $ID = $T.ID
    $Payload = $T.Payload
    $Tactic = ($T.Tactics -split ",")[0].Trim()
    
    if (-not $StatsByTactic.ContainsKey($Tactic)) {
        $StatsByTactic[$Tactic] = @{ "Total" = 0; "Ready" = 0 }
    }

    $GlobalTotal++
    $StatsByTactic[$Tactic].Total++

    # Vérification si le payload contient au moins une clé (Zéro Invention)
    $Keys = if ($null -ne $Payload) { $Payload.PSObject.Properties.Name } else { @() }
    
    if ($Keys.Count -gt 0) {
        $ReadyCount++
        $StatsByTactic[$Tactic].Ready++
    } else {
        $EmptyCount++
    }
}

# --- AFFICHAGE DU RAPPORT ---
Out-Spectre "--- RAPPORT DE COUVERTURE TACTIQUE ---" "DEBUG"
$StatsByTactic.GetEnumerator() | ForEach-Object {
    $Name = $_.Key
    $Total = $_.Value.Total
    $Ready = $_.Value.Ready
    $Percent = [math]::Round(($Ready / $Total) * 100, 2)
    
    $Color = if ($Percent -gt 50) { "SUCCESS" } elseif ($Percent -gt 0) { "WARN" } else { "DEBUG" }
    Out-Spectre "$Name : $Ready / $Total ($Percent%)" $Color
}

Write-Host "`n"
Out-Spectre "--- SYNTHESE GLOBALE ---" "DEBUG"
Out-Spectre "TOTAL TECHNIQUES : $GlobalTotal" "DEBUG"
Out-Spectre "OPERATIONNELLES  : $ReadyCount" "SUCCESS"
Out-Spectre "EN ATTENTE (VIDE) : $EmptyCount" "WARN"

$GlobalPercent = [math]::Round(($ReadyCount / $GlobalTotal) * 100, 2)
Out-Spectre "COUVERTURE GLOBALE : $GlobalPercent %" "DEBUG"