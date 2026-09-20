# Installation et maintenance

Le dossier de l'addon doit porter le nom `MidnightCompanion` et contenir le fichier `MidnightCompanion.toc` à sa racine. Ne placez pas un second dossier imbriqué entre `AddOns` et le fichier TOC.

Pour diagnostiquer un problème :

- activez les erreurs Lua avec `/console scriptErrors 1` ;
- rechargez avec `/reload` ;
- testez `/mc help`, `/mc show`, puis `/mc reset` ;
- vérifiez que le journal de combat est disponible pour les compteurs.

Les recommandations de classe et de spécialisation doivent être ajoutées uniquement avec une source vérifiable pour le patch ciblé. Une donnée inconnue doit rester vide afin d'éviter de pousser un joueur vers une action incorrecte.
