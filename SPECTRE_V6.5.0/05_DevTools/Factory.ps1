<#
.DESCRIPTION
    SPECTRE ATOMIC FACTORY - ADVANCED EDITION
    Version : V4.0.7 (Analysis Return Fix & Generic List)
    Reference : 2.83 | Lock : V4.9.3
    NB LIGNES : 230
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)][string]$TargetID,
    [Parameter(Mandatory=$false)][Switch]$Force
)

$ScriptPath = $MyInvocation.MyCommand.Path
$ToolsDir   = Split-Path $ScriptPath -Parent
$ProjectRoot = Split-Path $ToolsDir -Parent

$ProfilesDir = Join-Path $ProjectRoot "01_Profiles"
$AtomicDir   = Join-Path $ProjectRoot "02_Scripts_Atomic"
$BackupDir   = Join-Path $ProjectRoot "02_Scripts_Atomic_Backup_Staging"
$LibPath     = Join-Path $ProjectRoot "04_Tools_Lib\Spectre_Shared_Lib.psm1"

Write-Host "`n" + ("#"*60) -ForegroundColor Cyan
Write-Host "       SPECTRE FACTORY V4.0.7 - PRODUCTION READY" -ForegroundColor Cyan
Write-Host ("#"*60) -ForegroundColor Cyan

# --- PHASE 1 : STAGING ---
Write-Host "`n[1/3] STAGING : Nettoyage et Securisation..." -ForegroundColor Yellow
if (Test-Path $BackupDir) {
    Get-ChildItem -Path $BackupDir -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item $BackupDir -Recurse -Force -ErrorAction SilentlyContinue
}
if (Test-Path $AtomicDir) {
    New-Item -Path $BackupDir -ItemType Directory -Force | Out-Null
    Copy-Item -Path "$AtomicDir\*" -Destination $BackupDir -Recurse -Force -ErrorAction SilentlyContinue
}

# --- PHASE 2 : GENERATION ---
$PointsToProcess = [System.Collections.Generic.List[object]]::new()
$Profiles = Get-ChildItem -Path $ProfilesDir -Filter "*.json"

foreach ($Profile in $Profiles) {
    try {
        $RawJSON = Get-Content -Raw $Profile.FullName -Encoding utf8 | ConvertFrom-Json
        $KPoints = @($RawJSON.KnowledgePoints)
        
        foreach ($P in $KPoints) {
            if ([string]::IsNullOrWhiteSpace($TargetID) -or [string]$P.ID -eq [string]$TargetID) {
                $PointsToProcess.Add([PSCustomObject]@{ Data = $P; Group = $RawJSON.GroupName })
            }
        }
        Write-Host "[DEBUG] Profil $($Profile.Name) : $($KPoints.Count) charges." -ForegroundColor DarkGray
    } catch {
        Write-Warning "Erreur sur $($Profile.Name) : $($_.Exception.Message)"
    }
}

$Total = $PointsToProcess.Count
Write-Host "[2/3] GENERATION : $Total point(s) identifie(s)." -ForegroundColor Yellow
if ($Total -eq 0) { Write-Error "Echec : Liste vide."; return }

for ($i = 0; $i -lt $Total; $i++) {
    $Item = $PointsToProcess[$i]
    $Point = $Item.Data
    $GroupName = $Item.Group
    
    Write-Progress -Activity "Generation SPECTRE" -Status "ID: $($Point.ID)" -PercentComplete ([Math]::Round(($i / $Total) * 100))

    $TargetDir = Join-Path $AtomicDir $GroupName
    if (-not (Test-Path $TargetDir)) { New-Item -Path $TargetDir -ItemType Directory -Force | Out-Null }

    $SafeNote = $Point.FileNameNote -replace '[^\w]','_'
    $FilePath = Join-Path $TargetDir "P$($Point.ID)_$($GroupName)_$SafeNote.ps1"

    # Template V4.0.7 avec retour d'objet systematique pour l'Enforcer
    $Template = @'
<#
    ID: @ID@ | Name: @NAME@
    Artifact de comportement : V4.9.3 Lock
    Description : @DESC@
#>
[CmdletBinding()]
param([Switch]$Analyse, [Switch]$Commit, [Switch]$Rollback, [Switch]$DebugInfo, $CustomValue = $null)

$StartTime = [System.Diagnostics.Stopwatch]::StartNew()
$LibPath = Join-Path $PSScriptRoot "..\..\04_Tools_Lib\Spectre_Shared_Lib.psm1"
Import-Module $LibPath -Force
$Context = Get-SpectrePointRef -PointID "@ID@"

Write-Host "`n[ATOME @ID@] @NAME@" -ForegroundColor Cyan -Bold
$FinalTarget = if ($null -ne $CustomValue) { $CustomValue } else { if($Rollback){$Context.RollbackValue} else {$Context.TargetValue} }

$CurrentObj = Get-ItemProperty -Path $Context.RegPath -Name $Context.ValueName -ErrorAction SilentlyContinue
$CurrentVal = if($null -eq $CurrentObj.$($Context.ValueName)){'MISSING'}else{$CurrentObj.$($Context.ValueName)}

Write-Host "  [STATE] Current   : $CurrentVal" -ForegroundColor White
Write-Host "  [STATE] Target    : $FinalTarget" -ForegroundColor White

if ($Analyse) {
    $Status = if($CurrentVal -eq $FinalTarget){"ALREADY_CONFORM"}else{"NON_CONFORM"}
    return [PSCustomObject]@{ID="@ID@"; Name="@NAME@"; Status="ANALYSE_$Status"; Updated=$false}
}

$Result = Invoke-SpectreRegistryTransaction -Context $Context -Commit:$Commit -Rollback:$Rollback
$StartTime.Stop()
Write-Host "  [RESULT] Status    : $($Result.Status) ($($StartTime.Elapsed.TotalMilliseconds) ms)" -ForegroundColor Gray
return $Result
'@
    
    $FinalScript = $Template.Replace("@ID@", $Point.ID).Replace("@NAME@", $Point.Name).Replace("@DESC@", $Point.Notes)
    $FinalScript | Out-File -FilePath $FilePath -Encoding utf8 -Force
}

Write-Host "`n[3/3] VERIFICATION TERMINEE." -ForegroundColor Yellow
$Confirm = Read-Host "[?] Confirmer la generation (O/N)"
if ($Confirm -eq "O") {
    if (Test-Path $BackupDir) { Remove-Item $BackupDir -Recurse -Force -ErrorAction SilentlyContinue }
} else {
    if (Test-Path $AtomicDir) { Remove-Item $AtomicDir -Recurse -Force -ErrorAction SilentlyContinue }
    Move-Item -Path $BackupDir -Destination $AtomicDir -Force
}