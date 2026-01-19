<#
.DESCRIPTION
    SPECTRE MASTER ENFORCER - FULL VERBOSE EDITION
    Version : V1.4.9 (Fixed Structural Integrity - Curly Braces)
    Reference : 2.83 | Lock : V4.9.3 | Engineer Perspective
    NB LIGNES : 155
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)][string]$TargetID,
    [Parameter(Mandatory=$false)][Switch]$AnalyseOnly
)

$StartTimeTotal = [System.Diagnostics.Stopwatch]::StartNew()
$Segments = @("S_Silicon", "N_Network", "D_Defense", "U_User", "P_Privacy", "G_Governance")
$ProjectRoot = Split-Path $PSScriptRoot -Parent
$AtomicBase = Join-Path $ProjectRoot "02_Scripts_Atomic"
$LibPath = Join-Path $ProjectRoot "04_Tools_Lib\Spectre_Shared_Lib.psm1"

# Initialisation Globale de l'environnement
$Global:ProfilesDir = Join-Path $ProjectRoot "01_Profiles"

function Show-SpectreHeader([string]$Mode) {
    $Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "`n" + ("="*100) -ForegroundColor Cyan
    Write-Host "  SPECTRE V6.5.0 | $Date | MODE : $Mode" -ForegroundColor Cyan
    Write-Host ("="*100) + "`n" -ForegroundColor Cyan
}

# --- VERIFICATION DES DEPENDANCES ---
Write-Host "[DEBUG] Chargement de la librairie : $LibPath" -ForegroundColor DarkGray
if (Test-Path $LibPath) { 
    Import-Module $LibPath -Force 
    Write-Host "[DEBUG] Librairie chargee avec succes." -ForegroundColor DarkGray
} else {
    Write-Error "[FATAL] Shared Library introuvable." ; return
}

# --- PHASE 1 : AUDIT GLOBAL & COLLECTE ---
Show-SpectreHeader -Mode "AUDIT DE CONFORMITE SYSTEME"
$GlobalReport = @()

foreach ($SegName in $Segments) {
    Write-Host "[AUDIT] Scan du segment : $SegName" -ForegroundColor Cyan
    $SegPath = Join-Path $AtomicBase $SegName
    if (-not (Test-Path $SegPath)) { 
        Write-Host "  [!] Dossier absent, passage au segment suivant." -ForegroundColor DarkGray
        continue 
    }
    
    $Filter = if ($TargetID) { "P$($TargetID)_*.ps1" } else { "P*.ps1" }
    $Atoms = Get-ChildItem -Path $SegPath -Filter $Filter | Sort-Object Name

    foreach ($Atom in $Atoms) {
        Write-Host "  -> Analyse de l'atome : $($Atom.Name)... " -NoNewline -ForegroundColor White
        
        $Sw = [System.Diagnostics.Stopwatch]::StartNew()
        $Res = & $Atom.FullName -Analyse
        $Sw.Stop()

        if ($null -ne $Res) {
            $Meta = Get-SpectrePointRef -PointID $Res.ID
            if ($null -eq $Meta) { 
                Write-Host "ERREUR (Meta introuvable)" -ForegroundColor Red
                continue 
            }
            
            $StatusColor = if ($Res.Status -eq "ALREADY_CONFORM") { "Green" } else { "Yellow" }
            Write-Host "$($Res.Status) ($($Sw.Elapsed.TotalMilliseconds) ms)" -ForegroundColor $StatusColor
            
            $GlobalReport += [PSCustomObject]@{
                ID             = $Res.ID
                Name           = $Res.Name
                Group          = $SegName
                Domain         = $Meta.SubGroup
                Notes          = $Meta.Description
                Target         = $Meta.TargetValue
                Status         = [string]$Res.Status
                RebootRequired = [string]$Meta.RebootRequired
                FullName       = $Atom.FullName
                Updated        = $false
            }
        }
    }
}

# --- PHASE 2 : BILAN DES DERIVES ---
Write-Host "`n" + ("-"*100) -ForegroundColor Gray
$GlobalReport | Format-Table -Property ID, Name, Domain, Status, RebootRequired -AutoSize
$NonConform = @($GlobalReport | Where-Object { $_.Status -match "NON_CONFORM|MISSING" })

if ($NonConform.Count -eq 0) {
    Write-Host "[OK] Statut global : CONFORME." -ForegroundColor Green
    return
}

if ($AnalyseOnly) { return }

# --- PHASE 3 : ARBITRAGE DES FILES D'ATTENTE ---
Write-Host "`n[!] ALERTE : $($NonConform.Count) points ne respectent pas la norme." -ForegroundColor Yellow
Write-Host " [1] EXECUTION GLOBALE" ; Write-Host " [2] EXECUTION INTERACTIVE" ; Write-Host " [3] ABANDON"
$Choice = Read-Host "`n> Selection"

if ($Choice -match "1|2") {
    $Queue_Alpha = $NonConform | Where-Object { $_.RebootRequired -ne "Never" }
    $Omega_Weights = @{ "S_Silicon"=10; "N_Network"=20; "D_Defense"=30; "U_User"=40; "P_Privacy"=50; "G_Governance"=99 }

    $Queue_Omega = $NonConform | Where-Object { $_.RebootRequired -eq "Never" } | ForEach-Object {
        $Weight = if ($Omega_Weights.ContainsKey($_.Group)) { $Omega_Weights[$_.Group] } else { 50 }
        $_ | Add-Member -NotePropertyName "PriorityWeight" -NoteValue $Weight -PassThru
    } | Sort-Object PriorityWeight, ID

    $ProcessingOrder = $Queue_Alpha + $Queue_Omega

    # --- PHASE 4 : EXECUTION ---
    foreach ($Point in $ProcessingOrder) {
        $Apply = $true
        if ($Choice -eq "2") {
            Write-Host "`n" + ("*"*80) -ForegroundColor Cyan
            Write-Host "  ID / NOM   : [$($Point.ID)] $($Point.Name)"
            Write-Host "  CONTEXTE   : $($Point.Notes)"
            if ($Point.RebootRequired -eq "Never") { Write-Host "  PRIORITE   : OMEGA LOCK" -ForegroundColor Magenta }
            $Confirm = Read-Host "[?] Appliquer (O/N/S)"
            if ($Confirm -eq "N") { $Apply = $false } elseif ($Confirm -eq "S") { break }
        }

        if ($Apply) {
            Write-Host "[COMMIT] Execution ID:$($Point.ID)... " -NoNewline
            $Exec = & $Point.FullName -Commit
            if ($Exec.Status -eq "SUCCESS") {
                Write-Host "SUCCESS" -ForegroundColor Green
                $Point.Status = "FIXED" ; $Point.Updated = $true
            } else {
                Write-Host "FAILED ($($Exec.Status))" -ForegroundColor Red
            }
        }
    }

    # --- PHASE 5 : RAPPORT FINAL ---
    Show-SpectreHeader -Mode "SYNTHESE FINALE"
    $GlobalReport | Format-Table -Property ID, Name, Status, Updated -AutoSize
}

$StartTimeTotal.Stop()
Write-Host "[FIN] Session terminee en $($StartTimeTotal.Elapsed.TotalSeconds)s." -ForegroundColor Cyan