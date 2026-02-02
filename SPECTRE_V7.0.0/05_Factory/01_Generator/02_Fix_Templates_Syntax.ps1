<#
.DESCRIPTION
    NOM : 02_Fix_Templates_Syntax.ps1 | VERSION : 11.13
    ARCHITECTURE : SPECTRE V7.1.2 | [FIX] : Navigation parente et PS 5.1.
#>

# --- 1. ANCRAGE SUR LA STRUCTURE ISO-13 ---
$CurrentDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }

# Le script est dans 05_Factory\Generator, on remonte de 2 niveaux pour la racine
$ProjectRoot = Split-Path (Split-Path $CurrentDir -Parent) -Parent
$TplPath = Join-Path $ProjectRoot "00_Core\Templates"

Write-Host "[INIT] Racine : $ProjectRoot" -ForegroundColor Gray
Write-Host "[INIT] Cible  : $TplPath" -ForegroundColor Gray

# --- 2. VERIFICATION DU DOSSIER CIBLE ---
if (-not (Test-Path $TplPath)) {
    Write-Host "[ERREUR] Dossier Templates introuvable : $TplPath" -ForegroundColor Red
    return
}

# --- 3. CONTENU DES TEMPLATES (LOGIQUE PS 5.1) ---
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
        "Commit" { if (-not (Test-Path $Path)) { New-Item $Path -Force | Out-Null }; Set-ItemProperty -Path $Path -Name $Key -Value $ResolvedValue -Force; Out-Spectre "REG [$User] Applique : $Key" "SUCCESS" }
        "Rollback" { Remove-ItemProperty -Path $Path -Name $Key -EA 0; Out-Spectre "REG [$User] Restaure : $Key" "SUCCESS" }
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
                $Found = Test-Path $Resolved
                $Level = if ($Found) { "WARN" } else { "SUCCESS" }
                $Status = if ($Found) { "DETECTE" } else { "CLEAN" }
                Out-Spectre "FILE [$($P.Name)] $Status : $Goal" $Level
            }
            "Commit" { if (Test-Path $Resolved) { Move-Item -Path $Resolved -Destination "$Resolved.bak" -Force -EA 0; Out-Spectre "FILE [$($P.Name)] Neutralise" "SUCCESS" } }
            "Rollback" { if (Test-Path "$Resolved.bak") { Move-Item -Path "$Resolved.bak" -Destination $Resolved -Force -EA 0; Out-Spectre "FILE [$($P.Name)] Restaure" "SUCCESS" } }
        }
    }
}
'@

    "03_Template_Service.ps1" = @'
function Invoke-Action-Service {
    param($Target, $Goal, $Mode, $Value)
    $Srv = Get-Service -Name $Target -ErrorAction SilentlyContinue
    switch ($Mode) {
        "Audit" {
            if ($null -eq $Srv) { Out-Spectre "SERVICE ABSENT : $Target" "WARN"; return }
            $Status = if ($Srv.Status -eq "Stopped") { "PROTEGE" } else { "EXPOSE" }
            $Level = if ($Status -eq "PROTEGE") { "SUCCESS" } else { "WARN" }
            Out-Spectre "SERVICE $Target : $Status" $Level
        }
        "Commit" { if ($null -ne $Srv -and $Srv.Status -ne "Stopped") { Stop-Service -Name $Target -Force -EA 0; Out-Spectre "SERVICE STOPPE" "SUCCESS" } }
        "Rollback" { if ($null -ne $Srv -and $Srv.Status -eq "Stopped") { Start-Service -Name $Target -EA 0; Out-Spectre "SERVICE REDEMARRE" "SUCCESS" } }
    }
}
'@

    "04_Template_Process.ps1" = @'
function Invoke-Action-Process {
    param($Target, $Goal, $Mode, $Value)
    $Proc = Get-Process -Name $Target -ErrorAction SilentlyContinue
    switch ($Mode) {
        "Audit" {
            $IsActive = $null -ne $Proc
            $Level = if ($IsActive) { "WARN" } else { "SUCCESS" }
            $Status = if ($IsActive) { "ACTIF" } else { "INACTIF" }
            Out-Spectre "PROCESS $Target : $Status" $Level
        }
        "Commit" { if ($null -ne $Proc) { Stop-Process -Name $Target -Force -EA 0; Out-Spectre "PROCESS TUE" "SUCCESS" } }
        "Rollback" { Out-Spectre "ROLLBACK N/A POUR PROCESS" "DEBUG" }
    }
}
'@

    "05_Template_Hardware.ps1" = @'
function Invoke-Action-Hardware {
    param($Target, $Goal, $Mode, $Value)
    switch ($Mode) {
        "Audit" { Out-Spectre "HARDWARE $Target : En attente" "DEBUG" }
        "Commit" { Out-Spectre "HARDWARE $Target : Non defini" "DEBUG" }
        "Rollback" { Out-Spectre "HARDWARE $Target : Non defini" "DEBUG" }
    }
}
'@

    "06_Template_Timing.ps1" = @'
function Invoke-Action-Timing {
    param($Target, $Goal, $Mode, $Value)
    $Task = Get-ScheduledTask -TaskName $Target -ErrorAction SilentlyContinue
    switch ($Mode) {
        "Audit" {
            $Exists = $null -ne $Task
            $Level = if ($Exists) { "WARN" } else { "SUCCESS" }
            $Status = if ($Exists) { "PRESENTE" } else { "ABSENTE" }
            Out-Spectre "TASK $Target : $Status" $Level
        }
        "Commit" { if ($null -ne $Task) { Disable-ScheduledTask -TaskName $Target -EA 0; Out-Spectre "TASK DESACTIVEE" "SUCCESS" } }
        "Rollback" { if ($null -ne $Task) { Enable-ScheduledTask -TaskName $Target -EA 0; Out-Spectre "TASK ACTIVEE" "SUCCESS" } }
    }
}
'@
}

# --- 4. EXECUTION ---
foreach ($FileName in $Templates.Keys) {
    $FilePath = Join-Path $TplPath $FileName
    $Header = @"
<#
.DESCRIPTION
    NOM : $FileName | TYPE : Action Template
    ARCHITECTURE : SPECTRE V7.1.2 | [CONTRAINTES] : Zero accent. ASCII.
    LISTE DES OBLIGATIONS ET DIRECTIVES : 1. VERBOSITE TOTALE 2. ZERO INVENTION 3. ZERO AMPUTATION 4. AUDIT GRANULAIRE 5. REVERSIBILITE 6. VERIF. FONCTIONNELLE 7. DOC EMBARQUEE 8. CONFRONTATION 9. SEPARATION CORE/ATOME 10. PAS DE PARESSE 11. ISOLATION SCOPE 12. QUADRI-FONCTIONNALITE 13. LISTE VERTICALE 14. RESOLUTION SEMANTIQUE
#>
"@
    $FullContent = $Header + "`n" + $Templates[$FileName]
    $FullContent | Out-File -FilePath $FilePath -Encoding ascii -Force
    Write-Host "[FIX] Succes : $FileName" -ForegroundColor Green
}