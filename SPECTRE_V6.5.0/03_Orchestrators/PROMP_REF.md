# 🛠️ SPECTRE V6.5.0 - PROTOCOLE DE DEVELOPPEMENT MASTER ENFORCER

**Statut :** Strict Engineering Enforcement
**Référence Fonctionnelle :** V2.83
**Verrouillage de Norme :** V4.9.3

---

### 1. 📂 ARCHITECTURE & LOGIQUE DE FLUX
* **Non-Simplification :** Interdiction formelle de tronquer, échantillonner ou simplifier le code. Chaque réponse doit fournir le script intégral, prêt pour la production.
* **Cycle Audit-Action :** L'orchestrateur doit impérativement réaliser une Phase 1 d'Audit (switch `-Analyse`) avant toute proposition de modification.
* **Persistance des Données :** Utiliser des tableaux PowerShell natifs `@()` pour garantir la fiabilité des méthodes `.Count` et `.Add()`.

### 2. 🧬 MAPPING DES METADONNEES (SSoT)
Les objets de rapport et l'affichage console doivent s'aligner strictement sur les clés de la `Spectre_Shared_Lib.psm1` (V4.5.8) :
* **Domaine :** Propriété `.SubGroup` issue du SSoT.
* **Contexte :** Propriété `.Description` (mappée depuis `.Notes` dans le JSON).
* **Identifiant :** Clé `.ID`.

### 3. 🖥️ INTERFACE & VERBOSITE (ENGINEER PERSPECTIVE)
* **Terminologie :** Utiliser exclusivement "Artifact de comportement" au lieu de "comportement" ou "script".
* **Mode Interactif (Option [2]) :** Doit afficher un bloc de contexte structuré avant chaque validation :
    * `POINT` | `DOMAINE` | `CONTEXTE` | `CIBLE`.
* **Télémétrie :** Affichage systématique de la latence de transaction en millisecondes via `$AtomStartTime.Elapsed.TotalMilliseconds`.

### 4. 📊 REPORTING & AUDIT TRAIL
* **Calcul de Conformité :** Utiliser une logique de filtrage stricte (`-match "SUCCESS|ALREADY_CONFORM"`) pour éviter les faux positifs lors du calcul du taux global.
* **Archivage :** Génération automatique d'un export CSV délimité par des points-virgules (`;`) dans le répertoire `06_Logs` avec horodatage `yyyyMMdd_HHmm`.

### ⚠️ CLAUSE D'INTÉGRITÉ
Le modèle s'interdit de remettre en cause le **Point [25] (Target 4)** comme état conforme unique. Toute dérive par rapport à ces contraintes doit être signalée comme une anomalie de génération.