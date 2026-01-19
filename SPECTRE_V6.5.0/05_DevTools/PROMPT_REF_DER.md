# PROMPT POUR GENERER ATOMES:

# 🎯 BRIEFING OPERATIONNEL : [DEPOIEMENT DES ATOMS]

## 🏗️ SCOPE TECHNIQUE
* **Composant cible :** [Factory.ps1]
* **Objectif :** [
    Générer des atomes pilotables (-Analyse, -Commit, -Debug), collectant les informations du systeme, permettant au travers du Master_Enforcer, l'appliquer les correction, soit sur toutes les points, soit en choisissant le ou les points, dont les target values seront soit laissées par defauts, soit parametrée individuellement
]
* **Version de reference :** [Ex: v4.5.8 / v3.7.5]

## 🛠️ CONTRAINTES CRITIQUES (RAPPEL)
* **ASCII :** Zero accent dans le code et les reponses.
* **ISO-13 :** Utiliser les 14 descripteurs du SSoT (InherentImpact, Notes, FunctionalDomain...).
* **ADMIN :** Resolution de chemin absolue via $PSScriptRoot pour lecteur G:.
* **CODE :** Integral, non-tronque, non-echantillonne.

## 🔬 DETAILS SPECIFIQUES
* **Modification demandee :** [Decrire ici le changement exact]
* **Exemple de Data (JSON) :** [{
  "GroupName": "D_Defense",
  "Reference_ID": "2.83",
  "Version_Lock": "V4.9.3",
  "KnowledgePoints": [
    {
      "ID": "301",
      "MitreID": "T1562.001",
      "InherentImpact": 3,
      "FunctionalDomain": "Defense/Defender",
      "FileNameNote": "Defender_Antivirus_Disable",
      "Name": "Defender_Antivirus_Disable",
      "Notes": "Desactivation principale de Windows Defender Antivirus",
      "RegPath": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows Defender",
      "ValueName": "DisableAntiSpyware",
      "TargetValue": 1,
      "ValueType": "DWord",
      "RollbackValue": 0,
      "RebootRequired": true,
      "RequiredToken": "Admin"
    }]

## 🚀 RESULTAT ATTENDU
* [L'atome doit lever une erreur si le type de registre est different du SSoT]
* [Le Factory doit afficher une barre de progression]
* [Le factory doit donner la possibilité de modifier un seul atome, le choix se fait par l'ID du point]
* [Le factory doit integrer une possibilité de rollback / commit, avec interraction humaine (Oui/Non)]
* [le Factory doit etre tres verbeux]
* [Le factory doit proposer la target value par defaut]