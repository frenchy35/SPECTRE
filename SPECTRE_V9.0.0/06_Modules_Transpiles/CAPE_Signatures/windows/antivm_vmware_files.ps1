<#
.DESCRIPTION
    1.  Nom          : antivm_vmware_files.ps1
    2.  Auteur        : SPECTRE_GENERATOR
    3.  Date          : 30-01-2026
    4.  Version       : 1.0.0
    5.  Description   : Definition VMware : Detects VMware through the presence of a file
    6.  TTPs          : 'T1057', 'T1083', 'T1497'
    7.  MBCs          : 'OB0001', 'B0009', 'B0009.001', 'OB0007', 'E1083'
    8.  Categories    : 'anti-vm'
    9.  Audit_BDC     : Ce script a ete passe a la boucle de conformite.
#>

# Chargement de l infrastructure
. "$PSScriptRoot\..\..\..\00_Infrastructure\00_Configuration.ps1"

# --- DEFINITION DE L INTELLIGENCE (GRAIN) ---
$Spectre_Meta = @{{
    Name        = "antivm_vmware_files"
    Description = "Detects VMware through the presence of a file"
    Categories  = "'anti-vm'"
    TTPs        = "'T1057', 'T1083', 'T1497'"
    MBCs        = "'OB0001', 'B0009', 'B0009.001', 'OB0007', 'E1083'"
    Source      = "antivm_vmware_files.py"
}}

$Spectre_Indicators = @(
    ".*\\drivers\\vmmouse\.sys$",
    ".*\\drivers\\vmhgfs\.sys$",
    ".*\\vmguestlib\.dll$",
    ".*\\VMware\\ Tools\\TPAutoConnSvc\.exe$",
    ".*\\VMware\\ Tools\\TPAutoConnSvc\.exe\.dll$",
    ".*\\Program\\ Files(\\ \(x86\))?\\VMware\\VMware\\ Tools.*"
)

Write-Host " [LOAD] Definition technique chargee : antivm_vmware_files" -ForegroundColor Gray
