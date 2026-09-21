# Installation et maintenance

Le dossier de l'addon doit porter exactement le nom `MidnightCompanion` et contenir le fichier `MidnightCompanion.toc` à sa racine. Le ZIP 1.7.1 contient déjà cette structure :

```text
World of Warcraft\_retail_\Interface\AddOns\MidnightCompanion\
  MidnightCompanion.toc
  Core.lua
  Data.lua
  Combat.lua
  UI.lua
```

Le chemin du TOC doit être exactement `World of Warcraft\_retail_\Interface\AddOns\MidnightCompanion\MidnightCompanion.toc`. Il ne doit pas être placé dans un sous-dossier supplémentaire.

La langue est détectée automatiquement : interface française pour `frFR`, `frBE` et `frCA`, anglais de secours pour les autres locales. Les fichiers Lua et TOC sont enregistrés en UTF-8 ; les accents affichés sont intentionnels.

## Installation Retail

1. Téléchargez le ZIP de release et ouvrez-le.
2. Copiez le dossier unique `MidnightCompanion` dans `World of Warcraft\_retail_\Interface\AddOns\`.
3. Vérifiez que `MidnightCompanion.toc` est directement dans ce dossier, pas dans un sous-dossier.
4. Fermez et relancez WoW Retail, puis activez « Midnight Companion » dans la liste AddOns de l'écran de sélection.
5. En jeu, le message « Midnight Companion est chargé » doit apparaître. Utilisez `/mc status`, puis `/mc show` hors combat.

Pour diagnostiquer un problème :

- activez les erreurs Lua avec `/console scriptErrors 1` ;
- rechargez avec `/reload` ;
- testez `/mc help`, `/mc show`, puis `/mc reset` ;
- après connexion, le message `Midnight Companion est chargé` doit apparaître dans le chat ; utilisez `/mc status` pour confirmer que le TOC et l'interface sont actifs ;
- `/mc show` affiche toujours le tableau de bord hors combat ; `/mc toggle` le masque ou l'affiche ;
- le tableau de bord propose les onglets Aperçu, Équipement, Talents et Voyage ; les sections non inspectables indiquent « non vérifiable » au lieu de fabriquer un score ;
- `/mc report` imprime le dernier rapport dans le chat ;
- `/mc mage` affiche les téléportations et portails Mage dont l'API confirme la disponibilité ; une autre classe reçoit un message explicite ;
- `/mc travel` affiche le guide de voyage pour toutes les classes : destinations, portail de groupe, téléportation personnelle et alternatives sans invention ;
- `/mc details` imprime les conseils détaillés uniquement à la demande ;
- `/mc mode discovery|support|progression` ajuste la densité d'aide ;
- ne conservez qu'un seul dossier `MidnightCompanion` dans `Interface\AddOns` après chaque mise à jour.
- vérifiez que le journal de combat est disponible pour les compteurs.

## Nettoyage des anciennes copies

Depuis la racine du dépôt, lancez d'abord le mode aperçu :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\Cleanup-MidnightCompanion.ps1
```

Si la liste est correcte, ajoutez `-Apply` pour supprimer uniquement les dossiers `MidnightCompanion` et `MidnightCompanion-*`. Le script ne supprime aucun autre addon et ne parcourt pas tout le disque.

Pour une exécution par double-clic, utilisez `tools\Nettoyer-MidnightCompanion.cmd`. N'ouvrez pas directement le fichier `.ps1` dans l'éditeur Windows. Le lanceur se déporte automatiquement dans `%TEMP%` et change son répertoire courant avant de supprimer le dossier addon.

Fermez d'abord WoW : le script détecte tous les processus `Wow*` et refuse volontairement de supprimer un addon pendant que le jeu est ouvert. Battle.net peut rester ouvert. Fermez aussi tout terminal ou Explorateur positionné dans le dossier addon.

Les recommandations de classe et de spécialisation doivent être ajoutées uniquement avec une source vérifiable pour le patch ciblé. Une donnée inconnue doit rester vide afin d'éviter de pousser un joueur vers une action incorrecte.
