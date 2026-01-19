<#
.DESCRIPTION
    SPECTRE DOCUMENTATION GENERATOR
    Cree le manifeste de contraintes techniques pour verrouiller le developpement.
    NB LIGNES : 15
#>

$ProjectRoot = Split-Path $PSScriptRoot -Parent
$DocsDir = Join-Path $ProjectRoot "00_Docs"
$TargetFile = Join-Path $DocsDir "CONSTRAINTS.md"

if (-not (Test-Path $DocsDir)) { New-Item $DocsDir -ItemType Directory | Out-Null }

$Manifest = @"
# 🛠️ SPECTRE V6.5.0 - PROTOCOLE DE DEVELOPPEMENT MASTER ENFORCER

**Statut :** Strict Engineering Enforcement
**Reference Fonctionnelle :** V2.83
**Verrouillage de Norme :** V4.9.3

---

### 1. 📂 ARCHITECTURE & LOGIQUE DE FLUX
* **Non-Simplification :** Interdiction formelle de tronquer, echantillonner ou simplifier le code. Chaque reponse doit fournir le script integral.
* **Cycle Audit-Action :** L'orchestrateur doit imperativement realiser une Phase 1 d'Audit (switch -Analyse) avant toute proposition de modification.
* **Persistance des Donnees :** Utiliser des tableaux PowerShell natifs @() pour garantir la fiabilite des methodes .Count.

### 2. 🧬 MAPPING DES METADONNEES (SSoT)
Les objets de rapport et l'affichage console doivent s'aligner sur les cles de la Spectre_Shared_Lib.psm1 (V4.5.8) :
* **Domaine :** Propriete .SubGroup
* **Contexte :** Propriete .Description
* **Identifiant :** Cle .ID

### 3. 🖥️ INTERFACE & VERBOSITE
* **Terminologie :** Utiliser "Artifact de comportement" exclusivement.
* **Mode Interactif :** Affichage bloc de contexte structure (POINT, DOMAINE, CONTEXTE, CIBLE).
* **Telemetrie :** Affichage systematique de la latence via .TotalMilliseconds.

### 4. 📊 REPORTING & AUDIT TRAIL
* **Calcul :** Filtrage strict (-match "SUCCESS|ALREADY_CONFORM").
* **Archivage :** Generation CSV automatique dans 06_Logs avec separateur ";".

### ⚠️ CLAUSE D'INTEGRITE
Le point [25] (Target 4) est l'unique etat conforme.
"@

$Manifest | Out-File -FilePath $TargetFile -Encoding utf8 -Force
Write-Host "[OK] Manifeste de contraintes genere : $TargetFile" -ForegroundColor Green