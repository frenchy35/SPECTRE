<#
.DESCRIPTION
    NOM : Spectre_Shared_Lib.psm1 | VERSION : 10.0.0
    ARCHITECTURE : CORE LOGIC (ISO-13)
    FONCTION : Centralise les fonctions Invoke-Action-X avec support Omni-User.
    [CONTRAINTES] : Zero accent. Encodage ASCII.
#>

# --- 1. FONCTIONS DE LOGS (DIRECTIVE 1) ---
function Out-Spectre {
    param($M, $L="INFO")
    $C = switch($L){"SUCCESS"{"Green"} "WARN"{"Yellow"} "ERR"{"Red"} "DEBUG"{"Gray"} Default{"White"}}
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')][SPECTRE] $M" -ForegroundColor $C
}

# --- 2. TEMPLATE FILE (OMNI-USER) ---
function Invoke-Action-File {
    param($Target, $Goal, $Mode)
    
    # Resolution des profils (Directive 14)
    $Profiles = Get-ChildItem "C:\Users" -Directory -Exclude "Public", "All Users"
    
    foreach ($P in $Profiles) {
        # Si le chemin contient $env:USERPROFILE, on le remplace par le chemin du profil itere
        $ResolvedTarget = $Target -replace '\$env:USERPROFILE|C:\\Users\\[^\\]+', $P.FullName
        $ResolvedTarget = $ExecutionContext.InvokeCommand.ExpandString($ResolvedTarget)

        Out-Spectre "FILE [$Mode] sur $($P.Name) : $ResolvedTarget" "DEBUG"

        switch ($Mode) {
            "Audit" {
                if (Test-Path $ResolvedTarget) { Out-Spectre "ARTEFACT DETECTE : $ResolvedTarget" "WARN" }
            }
            "Commit" {
                if (Test-Path $ResolvedTarget) {
                    Move-Item -Path $ResolvedTarget -Destination "$ResolvedTarget.bak" -Force -EA 0
                    Out-Spectre "NEUTRALISE : $ResolvedTarget" "SUCCESS"
                }
            }
            "Rollback" {
                if (Test-Path "$ResolvedTarget.bak") {
                    Move-Item -Path "$ResolvedTarget.bak" -Destination $ResolvedTarget -Force -EA 0
                    Out-Spectre "RESTAURE : $ResolvedTarget" "SUCCESS"
                }
            }
        }
    }
}

# --- 3. TEMPLATE REGISTRY (OMNI-USER + HIVE MOUNTING) ---
function Invoke-Action-Registry {
    param($Target, $Goal, $Mode, $Value)

    # 1. Traitement HKLM (Global)
    if ($Target -like "HKLM:*") {
        Invoke-RegistryLogic -Path $Target -Key $Goal -Value $Value -Mode $Mode
        return
    }

    # 2. Traitement HKCU / HKU (Multi-Profil)
    $Profiles = Get-ChildItem "C:\Users" -Directory -Exclude "Public", "All Users"

    foreach ($P in $Profiles) {
        $NTUser = Join-Path $P.FullName "NTUSER.DAT"
        if (-not (Test-Path $NTUser)) { continue }

        $HiveName = "SPECTRE_TEMP_$($P.Name)"
        $Mounted = $false

        try {
            # Montage de la ruche si ce n est pas l utilisateur courant
            if ($P.Name -ne $env:USERNAME) {
                reg load "HKU\$HiveName" "$NTUser" 2>$null | Out-Null
                $CurrentPath = $Target -replace "HKCU:", "HKU:\$HiveName"
                $Mounted = $true
            } else {
                $CurrentPath = $Target
            }

            Invoke-RegistryLogic -Path $CurrentPath -Key $Goal -Value $Value -Mode $Mode -User $P.Name
        }
        finally {
            if ($Mounted) {
                [GC]::Collect()
                [GC]::WaitForPendingFinalizers()
                reg unload "HKU\$HiveName" 2>$null | Out-Null
            }
        }
    }
}

# --- 4. LOGIQUE INTERNE REGISTRE ---
function Invoke-RegistryLogic {
    param($Path, $Key, $Value, $Mode, $User="System")

    switch ($Mode) {
        "Audit" {
            $Reg = Get-ItemProperty -Path $Path -Name $Key -EA 0
            if ($null -ne $Reg -and $Reg.$Key -eq $Value) {
                Out-Spectre "PROTEGE [$User] : $Key" "SUCCESS"
            } else {
                Out-Spectre "EXPOSE [$User] : $Key" "WARN"
            }
        }
        "Commit" {
            if (-not (Test-Path $Path)) { New-Item $Path -Force | Out-Null }
            Set-ItemProperty -Path $Path -Name $Key -Value $Value -Force -EA 0
            Out-Spectre "APPLIQUE [$User] : $Key" "SUCCESS"
        }
        "Rollback" {
            Remove-ItemProperty -Path $Path -Name $Key -EA 0
            Out-Spectre "RETIRE [$User] : $Key" "SUCCESS"
        }
    }
}

Export-ModuleMember -Function Out-Spectre, Invoke-Action-Registry, Invoke-Action-File