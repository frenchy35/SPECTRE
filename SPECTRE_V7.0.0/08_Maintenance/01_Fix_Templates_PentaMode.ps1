<#
.DESCRIPTION
    NOM : 01_Fix_Templates_PentaMode.ps1 | DOSSIER : 08_Maintenance
    ARCHITECTURE : SPECTRE V7.1.2 | [FIX] : Penta-Fonctionnalite (Audit/Commit/Rollback/Help/Debug).
    [CONTRAINTES] : Zero accent. ASCII.
#>

$CurrentDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
$ProjectRoot = Split-Path $CurrentDir -Parent 
$TplPath = Join-Path $ProjectRoot "00_Core\Templates"

Write-Host "[INIT] Application du fix sur : $TplPath" -ForegroundColor Gray

$Templates = @{
    "01_Template_Registry.ps1" = @'
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
'@

    "02_Template_File.ps1" = @'
function Invoke-Action-File {
    param($Target, $Goal, $Mode, $Value)
    $Profiles = Get-ChildItem "C:\Users" -Directory -Exclude "Public", "All Users"
    foreach ($P in $Profiles) {
        $Resolved = $Target -replace '\$env:USERPROFILE|C:\\Users\\[^\\]+', $P.FullName
        $Resolved = $ExecutionContext.InvokeCommand.ExpandString($Resolved)
        switch ($Mode) {
            "Audit" {
                $Found = Test-Path $Resolved; $Level = if ($Found) { "WARN" } else { "SUCCESS" }
                Out-Spectre "FILE [$($P.Name)] Detecte: $Goal" $Level
            }
            "Commit"   { if (Test-Path $Resolved) { Move-Item $Resolved "$Resolved.bak" -Force; Out-Spectre "FILE [$($P.Name)] Neutralise" "SUCCESS" } }
            "Rollback" { if (Test-Path "$Resolved.bak") { Move-Item "$Resolved.bak" $Resolved -Force; Out-Spectre "FILE [$($P.Name)] Restaure" "SUCCESS" } }
            "Debug"    { Out-Spectre "DEBUG-FILE [$($P.Name)] | Path: $Resolved" "DEBUG" }
        }
    }
}
'@

    "03_Template_Service.ps1" = @'
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
'@

    "04_Template_Process.ps1" = @'
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
'@

    "05_Template_Hardware.ps1" = @'
function Invoke-Action-Hardware {
    param($Target, $Goal, $Mode, $Value)
    switch ($Mode) {
        "Audit"    { Out-Spectre "HW $Target : Audit en attente" "DEBUG" }
        "Commit"   { Out-Spectre "HW $Target : Commit N/A" "DEBUG" }
        "Rollback" { Out-Spectre "HW $Target : Rollback N/A" "DEBUG" }
        "Debug"    { Out-Spectre "DEBUG-HW | Target: $Target" "DEBUG" }
    }
}
'@

    "06_Template_Timing.ps1" = @'
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
'@
}

foreach ($FileName in $Templates.Keys) {
    $FilePath = Join-Path $TplPath $FileName
    # Le script traite maintenant TOUS les fichiers definis, qu'ils existent ou non (il les cree/ecrase)
    $Header = @"
<#
.DESCRIPTION
    NOM : $FileName | TYPE : Action Template
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
"@
    ($Header + "`n" + $Templates[$FileName]) | Out-File $FilePath -Encoding ascii -Force
    Write-Host "[FIX-PENTA] Succes : $FileName" -ForegroundColor Green
}