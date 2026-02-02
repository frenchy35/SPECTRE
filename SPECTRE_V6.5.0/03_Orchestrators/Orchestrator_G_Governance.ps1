<#
.DESCRIPTION
    SPECTRE SEGMENT ORCHESTRATOR
    Version Lock : V4.9.3 | Ref : 2.83
    Execute tous les atomes d'un segment specifique.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [Switch]$Commit,     # Appliquer les changements
    [Parameter(Mandatory=$false)]
    [Switch]$Rollback,   # Inversion des changements
    [Parameter(Mandatory=$false)]
    [String]$Segment = "G_Governance" # Valeur par defaut (A modifier par script)
)

$AtomicDir = Join-Path $PSScriptRoot "..\02_Scripts_Atomic\$Segment"
$Report = @()

Write-Host "--- SPECTRE ORCHESTRATOR : SEGMENT $Segment ---" -ForegroundColor Cyan
Write-Host "[INFO] Mode : $(if($Commit){'COMMIT'}elseif($Rollback){'ROLLBACK'}else{'AUDIT ONLY'})" -ForegroundColor Gray

if (-not (Test-Path $AtomicDir)) {
    Write-Error "[FATAL] Repertoire atomique introuvable : $AtomicDir" ; return
}

# Recuperation des atomes par ordre d'ID (P001, P002...)
$Atoms = Get-ChildItem -Path $AtomicDir -Filter "*.ps1" | Sort-Object Name

foreach ($Atom in $Atoms) {
    Write-Host "[EXEC] $($Atom.Name)... " -NoNewline -ForegroundColor White
    try {
        # Execution de l'atome (Bypass GPO via appel direct si necessaire)
        $Result = & $Atom.FullName -Commit:$Commit -Rollback:$Rollback
        $Report += $Result
        
        $Color = switch($Result.Status) {
            "SUCCESS" { "Green" }
            "ALREADY_CONFORM" { "Blue" }
            "FAILURE" { "Red" }
            default { "Yellow" }
        }
        Write-Host $Result.Status -ForegroundColor $Color
    }
    catch {
        Write-Host "CRITICAL_ERROR" -ForegroundColor Red
        Write-Warning "Echec d'execution sur $($Atom.Name)"
    }
}

# --- SYNTHESE DU SEGMENT ---
$Total = $Report.Count
$Gap   = ($Report | Where-Object { $_.Drift -eq $true }).Count
Write-Host "`n--- BILAN DE CONFORMITE ---" -ForegroundColor Yellow
Write-Host "Points Traites : $Total"
Write-Host "Derives Detectees : $Gap" -ForegroundColor $(if($Gap -gt 0){"Red"}else{"Gray"})

if ($Gap -eq 0) { Write-Host "[STATUS] SEGMENT CONFORME V4.9.3" -ForegroundColor Green }