<#
.DESCRIPTION
    SPECTRE SHARED LIBRARY - CORE ENGINE
    Version : V4.6.4 (Ultimate Verbose & Binary Type Safety)
    Reference : 2.83 | Lock : V4.9.3 | Engineer Perspective
    NB LIGNES : 152

    FONCTIONS :
    - Get-SpectrePointRef : Extraction des metadonnees depuis les profils JSON.
    - Invoke-SpectreRegistryTransaction : Gestionnaire atomique des ecritures registre.
    - Get-SpectreEnvironment : Audit du contexte d'execution.
#>

function Get-SpectrePointRef {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$PointID
    )

    Write-Host "[DEBUG] Recherche du PointID [$PointID] dans le SSoT..." -ForegroundColor DarkGray
    
    if (-not (Test-Path $Global:ProfilesDir)) { 
        Write-Error "Repertoire des profils introuvable : $Global:ProfilesDir"
        return $null 
    }

    $Profiles = Get-ChildItem -Path $Global:ProfilesDir -Filter "*.json"
    
    foreach ($File in $Profiles) {
        try {
            $SSoT = Get-Content -Raw $File.FullName -ErrorAction Stop | ConvertFrom-Json
            $Point = $SSoT.KnowledgePoints | Where-Object { [string]$_.ID -eq [string]$PointID }
            
            if ($null -ne $Point) {
                Write-Host "[DEBUG] Match trouve dans : $($File.Name)" -ForegroundColor DarkGray
                return [PSCustomObject]@{
                    ID                 = $Point.ID
                    Name               = $Point.Name
                    RegPath            = $Point.RegPath
                    ValueName          = $Point.ValueName
                    ValueType          = $Point.ValueType
                    TargetValue        = $Point.TargetValue
                    RollbackValue      = $Point.RollbackValue
                    Description        = $Point.Notes
                    Group              = $SSoT.GroupName
                    SubGroup           = $Point.FunctionalDomain
                    SourceProfile      = $File.Name
                    RebootRequired     = [string]$Point.RebootRequired
                }
            }
        } catch { 
            Write-Host "[!] Erreur de lecture sur $($File.Name) : $($_.Exception.Message)" -ForegroundColor Red
            continue 
        }
    }
    
    Write-Host "[!] PointID [$PointID] introuvable dans la base de connaissance." -ForegroundColor Yellow
    return $null
}

function Invoke-SpectreRegistryTransaction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][Object]$Context,
        [Switch]$Commit,
        [Switch]$Rollback,
        [Switch]$Silent
    )

    $Result = [PSCustomObject]@{ Status = "INITIALIZING"; Output = $null }

    try {
        if ($Commit -or $Rollback) {
            $ValToApply = if ($Rollback) { $Context.RollbackValue } else { $Context.TargetValue }
            
            # --- LOGIQUE DE CONVERSION BINAIRE (HOTFIX V4.6.3) ---
            if ($Context.ValueType -eq "Binary" -and $ValToApply -is [string]) {
                if (-not $Silent) { Write-Host "[DEBUG] Conversion String -> Binary (Unicode)..." -ForegroundColor DarkGray }
                $ValToApply = [System.Text.Encoding]::Unicode.GetBytes($ValToApply)
            }

            if (-not (Test-Path $Context.RegPath)) {
                if (-not $Silent) { Write-Host "[DEBUG] Creation du chemin de registre manquant..." -ForegroundColor DarkGray }
                New-Item -Path $Context.RegPath -Force | Out-Null
            }
            
            # Application de la valeur avec interruption stricte en cas d'erreur
            Set-ItemProperty -Path $Context.RegPath -Name $Context.ValueName -Value $ValToApply -Type $Context.ValueType -Force -ErrorAction Stop
            $Result.Status = "SUCCESS"
        } else {
            # --- MODE ANALYSE ---
            if (Test-Path $Context.RegPath) {
                $RegData = Get-ItemProperty -Path $Context.RegPath -Name $Context.ValueName -ErrorAction SilentlyContinue
                $CurrentVal = if ($null -ne $RegData) { $RegData.$($Context.ValueName) } else { $null }
                
                # Verification specifique pour les types binaires
                if ($Context.ValueType -eq "Binary" -and $null -ne $CurrentVal) {
                    $TargetBytes = [System.Text.Encoding]::Unicode.GetBytes($Context.TargetValue)
                    $CurrentHex = [System.BitConverter]::ToString($CurrentVal)
                    $TargetHex  = [System.BitConverter]::ToString($TargetBytes)
                    
                    if ($CurrentHex -eq $TargetHex) {
                        $Result.Status = "ALREADY_CONFORM"
                    } else { $Result.Status = "NON_CONFORM" }
                } elseif ($CurrentVal -eq $Context.TargetValue) {
                    $Result.Status = "ALREADY_CONFORM"
                } else {
                    $Result.Status = "NON_CONFORM"
                }
            } else {
                $Result.Status = "MISSING"
            }
        }
    } catch {
        $Result.Status = "TRANSACTION_FAILED"
        $Result.Output = $_.Exception.Message
        if (-not $Silent) { Write-Host "[!] TRANSACTION ERROR : $($_.Exception.Message)" -ForegroundColor Red }
    }

    return $Result
}

function Get-SpectreEnvironment {
    return [PSCustomObject]@{
        OS          = (Get-CimInstance Win32_OperatingSystem).Caption
        Version     = [System.Environment]::OSVersion.VersionString
        IsAdmin     = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        TimeStamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
}

Export-ModuleMember -Function Get-SpectrePointRef, Get-SpectreEnvironment, Invoke-SpectreRegistryTransaction