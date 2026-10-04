# Ordre de mission : opération "La Volière"

Analyse d'un serveur saisi.

## Contexte

Un serveur a été saisi lors du démantèlement d'un forum clandestin de revente de données volées, connu sous le nom de "la Volière". Il appartenait à son opérateur, qui se cache derrière le pseudonyme K0RB34U.

Tu fais partie de l'équipe d'analystes. Le serveur est de nouveau en ligne, isolé dans ton laboratoire. Personne n'en connaît les accès, ils ont été perdus lors de la saisie.

## Ta mission

- Pénétrer le serveur à partir de ce que tu trouveras par toi-même
- Remonter, compte par compte, l'organisation interne de la machine
- Extraire la preuve finale qui identifie l'opérateur et clôt l'enquête

K0RB34U a protégé chaque compte par un verrou logiciel de sa fabrication. Tu n'en as pas le code source. Analyser un verrou te donne la clé du compte suivant. C'est ainsi, de proche en proche, que tu progresses jusqu'à lui.

## Point d'entrée

On te fournit une seule information : l'adresse de la machine cible dans le laboratoire.

```
Cible : ____________________   (communiquée en début de séance)
```

Tout le reste est à découvrir. Commence par observer ce que la machine expose au réseau. Un service parle parfois plus qu'il ne le devrait.

## Ta trousse

Les outils que tu devrais avoir sous la main. À toi de juger lequel sert à quel moment.

- Reconnaissance réseau : nmap
- Exploration web et récupération de fichiers : un navigateur, curl, wget
- Connexion distante : ssh
- Analyse statique de binaires : file, strings, Ghidra
- Analyse dynamique : gdb avec pwndbg
- Calcul rapide et scripts : python3

## Indices, sans trop en dire

### Pour entrer

- Un service web peut cacher plus de pages qu'il n'en affiche. Les conventions du web indiquent parfois ce qu'on a voulu cacher.
- Les opérateurs négligents réutilisent des mots de passe prévisibles, construits selon une règle. Trouve la règle, tu trouves le mot de passe.

### Une fois dedans

- Chaque compte contient un dossier mission avec une note et un verrou. Lis la note, elle oriente sans donner la réponse.
- Les verrous se durcissent. Le premier se lit sans effort. Les suivants demandent de lire la logique, puis de la contourner, puis de déjouer une protection.
- Pour passer d'un compte au suivant, sers-toi de l'identifiant que le verrou t'a livré.

## Ce que tu rends

- Le flag final, la preuve qui identifie l'opérateur
- Un journal de bord par binôme : ton cheminement, les outils utilisés, tes impasses et comment tu les as levées. La démarche compte autant que le résultat.

## Cadre strict

Ces techniques ne s'exercent que sur la machine du laboratoire fournie pour ce TP. Toute intrusion hors de ce cadre est un délit.
