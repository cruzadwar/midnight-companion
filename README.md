# Midnight Companion

Midnight Companion est un addon WoW **d'aide à la décision**, lisible en jeu et sans automatisation. Il identifie la classe, la spécialisation et le rôle du personnage, affiche des priorités contextuelles DPS/tank/soins, signale des événements de survie et produit un bref rapport après combat.

Version actuelle : **1.0.0**

Pour supprimer les anciennes copies Windows avant une nouvelle installation, utilisez le nettoyeur fourni :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\Cleanup-MidnightCompanion.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\Cleanup-MidnightCompanion.ps1 -Apply
```

Vous pouvez aussi double-cliquer sur `tools\Nettoyer-MidnightCompanion.cmd`. Il affiche d'abord les copies trouvées, puis demande une confirmation avant suppression. Le lanceur se copie temporairement hors du dossier addon et change son répertoire courant vers `%TEMP%` avant de le supprimer, car Windows ne peut pas supprimer un dossier utilisé comme répertoire courant.

Fermez complètement WoW avant de lancer le nettoyage. Le script détecte les processus Retail et Classic (`Wow*`). Battle.net peut rester ouvert ; seul le jeu doit être fermé pour libérer les fichiers d'addons. Fermez aussi un terminal ou l'Explorateur positionné dans le dossier à supprimer.

La première commande fait uniquement un aperçu. Le nettoyage cible exclusivement les dossiers `MidnightCompanion` et `MidnightCompanion-*` dans les répertoires `Interface\AddOns` des installations WoW détectées. Si le jeu est installé ailleurs, ajoutez `-WorldOfWarcraftPath "C:\Chemin\World of Warcraft"`.

## Installation

1. Téléchargez ou clonez ce dépôt.
2. Copiez le dossier contenant `MidnightCompanion.toc`, `Core.lua`, `Combat.lua`, `Data.lua` et `UI.lua` dans `World of Warcraft/_retail_/Interface/AddOns/MidnightCompanion`.
3. Relancez le jeu ou utilisez « Recharger » à l'écran de sélection.
4. En jeu, utilisez `/mc show` pour afficher les recommandations dans le chat et `/mc help` pour les commandes.

## Fonctionnalités du MVP

- Détection via les API natives `UnitClass`, `GetSpecializationInfo` et `UnitGroupRolesAssigned`.
- Conseils génériques séparés par rôle, avec un état sûr quand aucune donnée n'est disponible, via le chat `/mc`.
- Alertes non intrusives lors de l'entrée en combat et après une mort détectée.
- Compteurs de dégâts subis, morts, interruptions et dispels tirés du journal de combat.
- Conseils et identité disponibles à la demande avec `/mc show`.
- Architecture data-driven (`Data.lua`) pour ajouter des entrées vérifiées par classe/spécialisation.
- Version 1.0 : `/mc show` affiche un tableau lisible avec identité, priorités de rôle, repère de classe, survie et conseils équipement/talents. Le contenu reste prudent : aucune rotation ni donnée de patch n'est inventée.

## Limites et sécurité

L'addon ne lance aucun sort, ne cible aucune unité, ne clique pas à la place du joueur et ne prend pas de décision automatisée. Il n'intègre pas encore de base de données de rencontres, de simulation d'équipement ou de recommandations de talents spécifiques au patch. Ces données doivent être ajoutées après vérification dans le jeu et peuvent changer avec chaque correctif.

Le champ `## Interface` du fichier TOC doit être ajusté si Blizzard change le numéro d'interface de Midnight. La version 0.7.0 est volontairement minimale pour isoler le popup : les conseils sont disponibles avec `/mc show`, mais la détection automatique et le rapport temps réel sont désactivés.

## Ajouter des données vérifiées

Ajoutez une entrée dans `Data.lua` après vérification d'un sort, d'un talent ou d'une mécanique dans la version cible. Le noyau doit rester indépendant de ces données : une entrée absente doit toujours produire un conseil générique, jamais une supposition.

## Validation

Le dépôt fournit une validation statique PowerShell sans dépendance externe :

```powershell
.\tests\validate-addon.ps1
```
