<#
.DESCRIPTION
    NOM : 03_Template_Service.ps1 | TYPE : Action Template
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
function Invoke-Action-Service {
    param($Target, $Goal, $Mode, $Value)
    $Srv = Get-Service -Name $Target -EA 0
    switch ($Mode) {
        "Audit" {
            if ($null -eq $Srv) { Out-Spectre "SRV ABSENT: $Target" "WARN"; return }
            $Status = if ($Srv.Status -eq "Stopped") { "PROTEGE" } else { "EXPOSE" }; $Level = if ($Status -eq "PROTEGE") { "SUCCESS" } else { "WARN" }
            Out-Spectre "SRV $Target : $Status" $Level
        }
        "Commit"   { if ($null -ne $Srv -and $Srv.Status -ne "Stopped") { Stop-Service $Target -Force; Out-Spectre "SRV STOPPE" "SUCCESS" } }
        "Rollback" { if ($null -ne $Srv -and $Srv.Status -eq "Stopped") { Start-Service $Target; Out-Spectre "SRV DEMARRE" "SUCCESS" } }
        "Debug"    { Out-Spectre "DEBUG-SRV | Name: $Target | Status: $(if($Srv){$Srv.Status}else{'Missing'})" "DEBUG" }
    }
}
