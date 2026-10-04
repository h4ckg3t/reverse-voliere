# TP Reverse Engineering : opération "La Volière"

Introduction au reverse engineering sur binaires. Mastère 2 cybersécurité.

## De quoi il s'agit

Un serveur a été saisi lors du démantèlement d'un forum clandestin de revente de données volées, "la Volière". Il appartenait à son opérateur, un individu qui se cache derrière le pseudonyme K0RB34U.

Tu es analyste. Ta mission : pénétrer ce serveur, remonter son organisation interne compte par compte, et extraire la preuve qui identifie l'opérateur. Chaque compte est protégé par un verrou logiciel. Analyser un verrou te donne la clé du compte suivant. De proche en proche, tu remontes jusqu'à K0RB34U.

Le reverse engineering est le moteur de toute l'enquête. Tu n'as le code source d'aucun verrou. À toi de comprendre ce qu'ils cachent.

## Comment ça marche

Le TP se déroule sur deux jours.

Le premier jour, tu montes ton environnement et tu apprends tes outils. Tu installes la machine cible, ta machine attaquante, et tu comprends à quoi servent Ghidra et gdb. Tu t'entraînes aussi au calcul d'octets, qui te servira pour un des verrous.

Le deuxième jour, tu mènes l'enquête. Tu pénètres le serveur et tu résous les verrous dans l'ordre.

## Par où commencer

Suis les documents dans l'ordre.

1. [Installation de l'environnement](01_Installation.md) : monter la cible et l'attaquant, installer les outils
2. [Les outils de l'analyste](02_Les_outils.md) : comprendre Ghidra et gdb, savoir lequel utiliser quand
3. [Calculer les octets à la main](03_Calcul_octets.md) : hexadécimal, binaire, XOR, avec un entraînement
4. [Ordre de mission](Brief_mission.md) : le contexte de l'enquête et tes consignes
5. [Aide-mémoire des commandes](04_Aide_memoire.md) : toutes les commandes regroupées, à garder ouvert

## La méthode

Pour chaque verrou, travaille toujours dans le même ordre. C'est cette méthode qui compte, plus que le résultat.

1. Boîte noire : lance le programme, teste-le, observe ce qu'il fait
2. Reconnaissance : file, strings, ltrace
3. Hypothèse : écris en une phrase ce que tu penses que le programme fait
4. Analyse : ouvre le binaire dans Ghidra ou gdb, lis la logique
5. Vérification : relance avec la bonne entrée, ou calcule la réponse

Tiens un journal de bord : ce que tu tentes, tes impasses, tes questions. Il est à rendre en fin de TP. La démarche compte autant que les flags.

## Cadre légal

Ces techniques ne s'exercent que sur la machine du laboratoire fournie pour ce TP. Toute intrusion sur un système sans autorisation est un délit. Ce que tu apprends ici est un savoir défensif, à utiliser dans un cadre légal.

---

h4ckg3t
