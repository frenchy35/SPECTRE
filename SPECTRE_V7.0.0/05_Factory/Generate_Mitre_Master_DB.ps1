<#
.DESCRIPTION
    NOM : Generate_Mitre_Master_DB.ps1 | VERSION : 8.0.7
    --- OBLIGATIONS ET CONTRAINTES SPECTRE ---
    1. VERBOSITE TOTALE 2. ZERO INVENTION 3. DATA-DRIVEN 4. COMPLET 5. OUT-SPECTRE
    6. COULEURS 7. TAMPER 8. DOC 9. TYPING 10. ASCII 11. ISOLATION 12. CLEANUP
    13. AUDIT 14. BYPASS
#>

function Out-Spectre {
    param([string]$M, [string]$L="INFO")
    $local_T = Get-Date -Format "HH:mm:ss.fff"
    $local_C = switch($L) { "ERR"{"Red"} "WARN"{"Yellow"} "SUCCESS"{"Green"} "DEBUG"{"Cyan"} Default{"Gray"} }
    $local_N = $M.Normalize([System.Text.NormalizationForm]::FormD)
    $local_B = [System.Text.Encoding]::ASCII.GetBytes($local_N)
    $local_Clean = [System.Text.Encoding]::ASCII.GetString($local_B).Replace('?', '')
    Write-Host "[$local_T][$L][SSOT_GEN] $local_Clean" -ForegroundColor $local_C
}

# CONFIGURATION
$ProjectRoot = "C:\Users\LGE\Mon Drive\PROJETS\EN_COURS\SPECTRE\SPECTRE_V7.0.0"
$local_RawSTIXPath = Join-Path $ProjectRoot "00_Core\enterprise-attack-raw.json"
$OutputPath = Join-Path $ProjectRoot "00_Core\MITRE_Master_DB.json"
$local_DoDownload = $true

Out-Spectre "Initialisation SSoT V8.0.7 - Rigueur de symetrie active" "DEBUG"

if (Test-Path $local_RawSTIXPath) {
    Out-Spectre "Base locale detectee. Analyse de l'age..." "DEBUG"
    $local_Prompt = Read-Host "[?] Forcer la synchronisation MITRE ? (Y/N)"
    if ($local_Prompt -ne "Y") { $local_DoDownload = $false }
}

if ($local_DoDownload) {
    try {
        Out-Spectre "TELECHARGEMENT : Synchronisation CTI..." "DEBUG"
        $local_Resp = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/mitre/cti/master/enterprise-attack/enterprise-attack.json" -UseBasicParsing
        $local_Resp.Content | Out-File $local_RawSTIXPath -Force
        $local_RawContent = $local_Resp.Content
    } catch { $local_RawContent = Get-Content $local_RawSTIXPath -Raw }
} else { $local_RawContent = Get-Content $local_RawSTIXPath -Raw }

$local_Data = $local_RawContent | ConvertFrom-Json
$local_MasterDB = @{ "Techniques" = @{} }
$local_PayloadMap = @{
    "T1497.001" = @{ "Actions" = @( @{ "T" = "File"; "Target" = "C:\Windows\System32\drivers\vboxguest.sys"; "Goal" = "Detect" } ) }
    "T1012"     = @{ "Actions" = @( @{ "T" = "Registry"; "Path" = "HKLM:\HARDWARE\Description\System"; "Key" = "SystemBiosVersion"; "Match" = "VBOX"; "Goal" = "Detect" } ) }
    "T1082"     = @{ "Actions" = @( @{ "T" = "Hardware"; "MinRAM" = "4"; "MinCPU" = "2"; "MacPrefix" = "00:0C:29"; "Goal" = "Detect" } ) }
    "T1497.003" = @{ "Actions" = @( @{ "T" = "Timing"; "SleepTime" = "30"; "Goal" = "Detect" } ) }
}

foreach ($local_Item in ($local_Data.objects | Where-Object { $_.type -eq "attack-pattern" -and -not $_.revoked })) {
    $local_ID = ($local_Item.external_references | Where-Object { $_.source_name -eq "mitre-attack" }).external_id | Select-Object -First 1
    if (-not $local_ID) { continue }
    $local_Payload = if ($local_PayloadMap.ContainsKey($local_ID)) { $local_PayloadMap[$local_ID] } else { @{ "Actions" = @() } }
    $local_MasterDB.Techniques[$local_ID] = @{ "ID" = $local_ID; "Name" = $local_Item.name; "Description" = $local_Item.description; "Payload" = $local_Payload }
}

$local_MasterDB | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding utf8 -Force
Out-Spectre "Master DB V8.0.7 finalise avec symetrie." "SUCCESS"