# Installation et maintenance

Le dossier de l'addon doit porter le nom `MidnightCompanion` et contenir le fichier `MidnightCompanion.toc` à sa racine. Ne placez pas un second dossier imbriqué entre `AddOns` et le fichier TOC.

Pour diagnostiquer un problème :

- activez les erreurs Lua avec `/console scriptErrors 1` ;
- rechargez avec `/reload` ;
- testez `/mc help`, `/mc show`, puis `/mc reset` ;
- la version 0.7.0 affiche les conseils dans le chat et ne charge aucune frame ni événement ;
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
