<#
.DESCRIPTION
    NOM : 06_Template_Timing.ps1 | TYPE : Action Template
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
function Invoke-Action-Timing {
    param($Target, $Goal, $Mode, $Value)
    $Task = Get-ScheduledTask -TaskName $Target -EA 0
    switch ($Mode) {
        "Audit"    { $Level = if ($null -ne $Task) { "WARN" } else { "SUCCESS" }; Out-Spectre "TASK $Target : $(if($Task){'PRESENTE'}else{'ABSENTE'})" $Level }
        "Commit"   { if ($null -ne $Task) { Disable-ScheduledTask -TaskName $Target; Out-Spectre "TASK DESACTIVEE" "SUCCESS" } }
        "Rollback" { if ($null -ne $Task) { Enable-ScheduledTask -TaskName $Target; Out-Spectre "TASK ACTIVEE" "SUCCESS" } }
        "Debug"    { Out-Spectre "DEBUG-TASK | Name: $Target | State: $(if($Task){$Task.State}else{'Missing'})" "DEBUG" }
    }
}
