# Midnight Companion

Midnight Companion est un addon WoW **d'aide à la décision**, lisible en jeu et sans automatisation. Il identifie la classe, la spécialisation et le rôle du personnage, affiche des priorités contextuelles DPS/tank/soins, signale des événements de survie et produit un bref rapport après combat.

Version actuelle : **0.1.2**

## Installation

1. Téléchargez ou clonez ce dépôt.
2. Copiez le dossier contenant `MidnightCompanion.toc`, `Core.lua`, `Combat.lua`, `Data.lua` et `UI.lua` dans `World of Warcraft/_retail_/Interface/AddOns/MidnightCompanion`.
3. Relancez le jeu ou utilisez « Recharger » à l'écran de sélection.
4. En jeu, utilisez `/mc` pour ouvrir/masquer le panneau et `/mc help` pour les commandes.

## Fonctionnalités du MVP

- Détection via les API natives `UnitClass`, `GetSpecializationInfo` et `UnitGroupRolesAssigned`.
- Conseils génériques séparés par rôle, avec un état sûr quand aucune donnée n'est disponible.
- Alertes non intrusives lors de l'entrée en combat et après une mort détectée.
- Compteurs de dégâts subis, morts, interruptions et dispels tirés du journal de combat.
- Rapport post-combat avec durée et actions prioritaires.
- Architecture data-driven (`Data.lua`) pour ajouter des entrées vérifiées par classe/spécialisation.
- Panneau fixe sans fonctions d'interface protégées, pour rester compatible avec les restrictions Blizzard.

## Limites et sécurité

L'addon ne lance aucun sort, ne cible aucune unité, ne clique pas à la place du joueur et ne prend pas de décision automatisée. Il n'intègre pas encore de base de données de rencontres, de simulation d'équipement ou de recommandations de talents spécifiques au patch. Ces données doivent être ajoutées après vérification dans le jeu et peuvent changer avec chaque correctif.

Le champ `## Interface` du fichier TOC doit être ajusté si Blizzard change le numéro d'interface de Midnight. Les métriques du journal de combat sont volontairement limitées aux événements que l'API expose de manière stable.

## Ajouter des données vérifiées

Ajoutez une entrée dans `Data.lua` après vérification d'un sort, d'un talent ou d'une mécanique dans la version cible. Le noyau doit rester indépendant de ces données : une entrée absente doit toujours produire un conseil générique, jamais une supposition.

## Validation

Le dépôt fournit une validation statique PowerShell sans dépendance externe :

```powershell
.\tests\validate-addon.ps1
```
