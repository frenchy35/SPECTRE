<#
.DESCRIPTION
    NOM : Master_Enforcer.ps1
    VERSION : 1.9.2
    
    [CONTRAINTES TECHNIQUES MEMORISEES] :
    - Pas d'accents dans le code (Compatibilite totale).
    - Toujours integrer une fonction de debug (Tracabilite).
    - Pas de reboot du guest en cours d'analyse (Contrainte forte).
    - Utilisation d'un code couleur professionnel (Cyan/Green/Yellow/Red/Gray).
    - Verification bloquante de la desactivation de la Tamper Protection.
    - Stratification des flux : Eclatement vertical total par regex lookahead.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)][string]$TargetID,
    [Parameter(Mandatory=$false)][Switch]$AnalyseOnly,
    [Parameter(Mandatory=$false)][Switch]$DebugMode
)

$StartTimeTotal = [System.Diagnostics.Stopwatch]::StartNew()
$Segments = @("S_Silicon", "N_Network", "D_Defense", "U_User", "P_Privacy", "G_Governance")
$ProjectRoot = Split-Path $PSScriptRoot -Parent
$AtomicBase = Join-Path $ProjectRoot "02_Scripts_Atomic"
$LibPath = Join-Path $ProjectRoot "04_Tools_Lib\Spectre_Shared_Lib.psm1"

# --- CONFIGURATION DU CONTEXTE ---
$env:SPECTRE_PROFILES = Join-Path $ProjectRoot "01_Profiles"
$env:SPECTRE_DEBUG = if ($DebugMode) { "1" } else { "0" }

function Show-SpectreHeader([string]$Mode) {
    Write-Host "`n" + ("="*100) -ForegroundColor Cyan
    Write-Host "  SPECTRE V6.5.0 | $(Get-Date -Format 'HH:mm:ss') | MODE : $Mode" -ForegroundColor Cyan
    Write-Host ("="*100) + "`n" -ForegroundColor Cyan
}

# --- PHASE 0 : VERIFICATION TAMPER PROTECTION (CONSIGNE MEMORISEE) ---
Write-Host "[CHECK] Verification de la Tamper Protection... " -NoNewline -ForegroundColor White
$TamperStatus = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features" -Name "TamperProtection" -ErrorAction SilentlyContinue

if ($null -ne $TamperStatus -and $TamperStatus.TamperProtection -eq 5) {
    Write-Host "ACTIVE" -ForegroundColor Red
    Write-Host "`n[FATAL ERROR] La Tamper Protection bloque l'orchestrateur." -ForegroundColor White -BackgroundColor Red
    exit 1
} else { Write-Host "DESACTIVEE" -ForegroundColor Green }

if (Test-Path $LibPath) { Import-Module $LibPath -Force } else { return }

# --- PHASE 1 : AUDIT ---
Show-SpectreHeader -Mode "PHASE 1 : AUDIT DE CONFORMITE"
$GlobalReport = @()

foreach ($SegName in $Segments) {
    $SegPath = Join-Path $AtomicBase $SegName
    if (-not (Test-Path $SegPath)) { continue }
    $Atoms = Get-ChildItem -Path $SegPath -Filter "P*.ps1" | Sort-Object Name

    foreach ($Atom in $Atoms) {
        Write-Host "  [AUDIT] $($Atom.BaseName.PadRight(50,'.')) " -NoNewline -ForegroundColor White
        
        $Silence = if ($env:SPECTRE_DEBUG -eq "0") { "4>`$null 5>`$null 6>`$null" } else { "" }
        
        $RawOutput = powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "
            `$Global:ProfilesDir = '$($env:SPECTRE_PROFILES)';
            `$ProgressPreference = 'SilentlyContinue';
            `$obj = & '$($Atom.FullName)' -Analyse;
            if (`$obj) { `$obj | ConvertTo-Json -Compress }
        " $Silence 2>&1

        $RawString = [string]$RawOutput
        $Res = $null
        if ($RawString -match '(?s)\{.*\}') {
            try { $Res = $Matches[0] | ConvertFrom-Json } catch { }
        }

        if ($null -ne $Res -and $null -ne $Res.ID) {
            $StatusColor = switch -Wildcard ($Res.Status) { "*ALREADY_CONFORM" {"Green"} "*NON_CONFORM" {"Yellow"} Default {"Red"} }
            Write-Host "$($Res.Status)" -ForegroundColor $StatusColor
            
            # --- STRATIFICATION RADICALE DU DEBUG (V1.9.2) ---
            if ($env:SPECTRE_DEBUG -eq "1" -and $RawString) {
                $OnlyText = $RawString.Replace($Matches[0], "").Trim()
                # Split ameliore : On decoupe sur les balises peu importe l'espacement
                $Stratified = $OnlyText -split "(?=\[DEBUG\])|(?=\[ATOME\])|(?=\[STATE\])|(?=\[RESULT\])" | Where-Object { $_.Trim() -ne "" }
                
                foreach ($Line in $Stratified) {
                    Write-Host "    > $($Line.Trim())" -ForegroundColor Gray
                }
            }

            $GlobalReport += [PSCustomObject]@{
                ID = $Res.ID ; Name = $Res.Name ; Group = $SegName ; Status = [string]$Res.Status ; FullName = $Atom.FullName
            }
        } else { 
            Write-Host "SKIP" -ForegroundColor Gray 
        }
    }
}

# --- PHASE 2 : ACTION ---
$NonConform = @($GlobalReport | Where-Object { $_.Status -match "NON_CONFORM|MISSING" })
if ($NonConform.Count -gt 0 -and -not $AnalyseOnly) {
    Write-Host "`n" + ("-"*100) -ForegroundColor Gray
    Write-Host "[!] ALERTE : $($NonConform.Count) points de divergence detectes." -ForegroundColor Yellow
    
    if ((Read-Host " [1] Lancer le Commit Global [2] Abandonner") -eq "1") {
        foreach ($Point in $NonConform) {
            Write-Host "  [COMMIT] $($Point.ID) | $($Point.Name.PadRight(45,'.')) " -NoNewline
            $Silence = if ($env:SPECTRE_DEBUG -eq "0") { "4>`$null 5>`$null 6>`$null" } else { "" }
            
            $ExecRaw = powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "
                `$Global:ProfilesDir = '$($env:SPECTRE_PROFILES)';
                `$obj = & '$($Point.FullName)' -Commit;
                if (`$obj) { `$obj | ConvertTo-Json -Compress }
            " $Silence 2>&1
            
            if ($ExecRaw -match '(?s)\{.*\}') { Write-Host "SUCCESS" -ForegroundColor Green }
            else { Write-Host "FAILED" -ForegroundColor Red }
        }
    }
}

$StartTimeTotal.Stop()
Write-Host "`n[FIN] Session terminee en $([Math]::Round($StartTimeTotal.Elapsed.TotalSeconds, 2))s." -ForegroundColor Cyan