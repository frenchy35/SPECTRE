<#
.DESCRIPTION
    NOM : 01_Template_Registry.ps1 | TYPE : Action Template
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
function Invoke-Action-Registry {
    param($Target, $Goal, $Mode, $Value)
    if ($Target -like "HKLM:*") { Invoke-RegistryInternal -Path $Target -Key $Goal -Value $Value -Mode $Mode -User "System" }
    else {
        $Profiles = Get-ChildItem "C:\Users" -Directory -Exclude "Public", "All Users"
        foreach ($P in $Profiles) {
            $HiveName = "SPECTRE_HIVE_$($P.Name)"; $Mounted = $false
            try {
                if ($P.Name -ne $env:USERNAME) {
                    $NTUser = Join-Path $P.FullName "NTUSER.DAT"
                    if (Test-Path $NTUser) { reg load "HKU\$HiveName" "$NTUser" 2>$null | Out-Null; $CurrentPath = $Target -replace "HKCU:", "HKU:\$HiveName"; $Mounted = (Test-Path $CurrentPath) }
                } else { $CurrentPath = $Target }
                Invoke-RegistryInternal -Path $CurrentPath -Key $Goal -Value $Value -Mode $Mode -User $P.Name
            } finally { if ($Mounted) { [GC]::Collect(); [GC]::WaitForPendingFinalizers(); reg unload "HKU\$HiveName" 2>$null | Out-Null } }
        }
    }
}
function Invoke-RegistryInternal {
    param($Path, $Key, $Value, $Mode, $User)
    $ResolvedValue = $ExecutionContext.InvokeCommand.ExpandString($Value)
    switch ($Mode) {
        "Audit" {
            $Reg = Get-ItemProperty -Path $Path -Name $Key -EA 0
            $Status = if ($null -ne $Reg -and $Reg.$Key -eq $ResolvedValue) { "PROTEGE" } else { "EXPOSE" }
            $Level = if ($Status -eq "PROTEGE") { "SUCCESS" } else { "WARN" }
            Out-Spectre "REG [$User] $Key : $Status" $Level
        }
        "Commit"   { if (-not (Test-Path $Path)) { New-Item $Path -Force | Out-Null }; Set-ItemProperty -Path $Path -Name $Key -Value $ResolvedValue -Force; Out-Spectre "REG [$User] Applique : $Key" "SUCCESS" }
        "Rollback" { Remove-ItemProperty -Path $Path -Name $Key -EA 0; Out-Spectre "REG [$User] Restaure : $Key" "SUCCESS" }
        "Debug"    { Out-Spectre "DEBUG-REG [$User] | Path: $Path | Key: $Key | Expected: $ResolvedValue" "DEBUG" }
    }
}
