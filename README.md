# Midnight Companion

Midnight Companion est un addon WoW **d'aide à la décision**, lisible en jeu et sans automatisation. Il identifie la classe, la spécialisation et le rôle du personnage, affiche des priorités contextuelles DPS/tank/soins, signale des événements de survie et produit un bref rapport après combat.

Version actuelle : **0.5.6**

Pour supprimer les anciennes copies Windows avant une nouvelle installation, utilisez le nettoyeur fourni :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\Cleanup-MidnightCompanion.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\Cleanup-MidnightCompanion.ps1 -Apply
```

Vous pouvez aussi double-cliquer sur `tools\Nettoyer-MidnightCompanion.cmd`. Il affiche d'abord les copies trouvées, puis demande une confirmation avant suppression. Le lanceur se copie temporairement hors du dossier addon avant de le supprimer, car Windows ne peut pas supprimer un script en cours d'exécution depuis ce même dossier.

Fermez complètement WoW avant de lancer le nettoyage. Battle.net peut rester ouvert ; seul le jeu doit être fermé pour libérer les fichiers d'addons.

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
- Une frame d'événements non protégée collecte les changements de groupe/spécialisation et les événements de combat.
- Un panneau fixe anonyme utilise uniquement une frame normale et des textures/fontstrings ; aucun template sécurisé ni frame Blizzard n'est modifié.
- Une seule frame normale anonyme est créée après `/mc show`; aucun enfant de frame et aucun masquage initial ne sont utilisés.

## Limites et sécurité

L'addon ne lance aucun sort, ne cible aucune unité, ne clique pas à la place du joueur et ne prend pas de décision automatisée. Il n'intègre pas encore de base de données de rencontres, de simulation d'équipement ou de recommandations de talents spécifiques au patch. Ces données doivent être ajoutées après vérification dans le jeu et peuvent changer avec chaque correctif.

Le champ `## Interface` du fichier TOC doit être ajusté si Blizzard change le numéro d'interface de Midnight. Les métriques du journal de combat sont volontairement limitées aux événements que l'API expose de manière stable. La version 0.5.0 utilise une frame normale conforme aux patterns d'addons connus. Les alertes restent textuelles et non automatisées ; aucune action de sort, ciblage ou clic n'est exécutée.

## Ajouter des données vérifiées

Ajoutez une entrée dans `Data.lua` après vérification d'un sort, d'un talent ou d'une mécanique dans la version cible. Le noyau doit rester indépendant de ces données : une entrée absente doit toujours produire un conseil générique, jamais une supposition.

## Validation

Le dépôt fournit une validation statique PowerShell sans dépendance externe :

```powershell
.\tests\validate-addon.ps1
```
