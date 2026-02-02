<#
.DESCRIPTION
    NOM : 04_Template_Process.ps1 | TYPE : Action Template
    ARCHITECTURE : SPECTRE V7.1.2 | [PENTA-MODE] : Audit, Commit, Rollback, Help, Debug.
    LISTE DES OBLIGATIONS ET DIRECTIVES :
    1. VERBOSITE TOTALE
    2. ZERO INVENTION
    3. ZERO AMPUTATION
    4. AUDIT GRANULAIRE
    5. REVERSIBILITE
    6. VERIF. FONCTIONNELLE
    7. DOC EMBARQUEE
    8. CONFRONTATION
    9. SEPARATION CORE/ATOME
    10. PAS DE PARESSE
    11. ISOLATION SCOPE
    12. QUADRI-FONCTIONNALITE
    13. LISTE VERTICALE
    14. RESOLUTION SEMANTIQUE
#>
function Invoke-Action-Process {
    param($Target, $Goal, $Mode, $Value)
    $Proc = Get-Process -Name $Target -EA 0
    switch ($Mode) {
        "Audit"    { $Level = if ($null -ne $Proc) { "WARN" } else { "SUCCESS" }; Out-Spectre "PROC $Target : $(if($Proc){'ACTIF'}else{'INACTIF'})" $Level }
        "Commit"   { if ($null -ne $Proc) { Stop-Process -Name $Target -Force; Out-Spectre "PROC TUE" "SUCCESS" } }
        "Rollback" { Out-Spectre "ROLLBACK N/A POUR PROCESS" "DEBUG" }
        "Debug"    { Out-Spectre "DEBUG-PROC | Name: $Target | PID: $(if($Proc){$Proc.Id}else{'N/A'})" "DEBUG" }
    }
}
