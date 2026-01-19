# SPECTRE V7.1.2 - Hardening Framework

SPECTRE est un framework modulaire d audit et de remediation (Hardening) pour environnements Windows, s appuyant sur une architecture atomique et un SSoT (Source Unique de Verite).

---

## 📂 Architecture du Projet (ISO-13)

| Dossier | Fonction | Description |
| :--- | :--- | :--- |
| **00_Core** | Kernel | Logique noyau et librairies partagees (Shared Lib). |
| **01_SSoT** | Knowledge | Definitions techniques des points de controle (JSON). |
| **02_Atoms** | Execution | Scripts PowerShell unitaires generes par la Factory. |
| **03_Engine** | Orchestrator | Master Enforcer : Moteur de conformite et de commit. |
| **04_Vault** | Profiles | Valeurs cibles et configurations specifiques. |
| **05_Factory** | Build | Outils de generation automatique des atomes. |
| **06_Out** | Data | Sorties dynamiques : Logs, Rapports et Backups. |
| **07_Docs** | Manuals | Documentation technique et mapping MITRE ATT&CK. |

---

## 🚀 Workflow Standard

### 1. Initialisation
Deploiement de l infrastructure de base :
```powershell
.\bootstrap_v7.ps1
```

### 2. Generation (Factory)
Creation des atomes a partir des definitions JSON :
```powershell
.\05_Factory\Generator\Atom_Generator.ps1 -Force
```

### 3. Audit (Engine)
Analyse de la conformite du systeme :
```powershell
.\03_Engine\Master_Enforcer.ps1
```

### 4. Debug (Diagnostic)
Visualisation detaillee des etats Current/Target :
```powershell
.\03_Engine\Master_Enforcer.ps1 -DebugMode
```

---

## 🛡️ Contraintes de Securite et Design

* **Zero Accent** : Aucun caractere special dans le code source (ASCII pur).
* **Tamper Protection** : Verification bloquante du statut de protection Windows Defender.
* **Dual-Logging** : Archivage automatique de chaque session dans 06_Out\Logs.
* **Immuabilite** : Les fichiers dans 02_Atoms ne sont jamais edites manuellement.

---

## 📝 Documentation Additionnelle
- [Structure Detaillee](07_Docs/Technical/STRUCTURE.md)
- [Historique des Versions](07_Docs/Changelogs/VERSION.txt)
- [Standards MITRE](07_Docs/Security_Standard/MITRE_Mapping.txt)