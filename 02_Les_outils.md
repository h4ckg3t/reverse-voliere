# Les outils de l'analyste

Avant de t'attaquer aux verrous, tu dois comprendre tes outils. En reverse engineering, tu n'as pas le code source d'un programme, juste le programme compilé. Ton travail est de comprendre ce qu'il fait et comment, à partir de ce fichier seul. Pour ça, tu as deux grandes familles d'outils et deux grandes approches.

## Les deux approches

**L'analyse statique**, c'est lire le programme sans le lancer. Tu ouvres le binaire, tu regardes son code, tu comprends sa logique sans jamais l'exécuter. C'est comme lire une recette pour comprendre un plat sans le cuisiner.

**L'analyse dynamique**, c'est observer le programme pendant qu'il tourne. Tu le lances dans un environnement contrôlé, tu l'arrêtes où tu veux, tu regardes ce qui se passe en mémoire, tu peux même changer son comportement en cours de route. C'est goûter et ajuster pendant la cuisson.

Les deux se complètent. Souvent tu lis d'abord en statique pour comprendre la structure, puis tu passes en dynamique pour agir.

## Qu'est-ce qu'un binaire

Quand un développeur écrit un programme en C, il produit du code source lisible. Pour que la machine l'exécute, ce code est compilé, transformé en instructions machine. Le résultat est le binaire, un fichier d'instructions que le processeur comprend mais qui n'est plus lisible pour un humain.

La compilation est à sens unique. On ne peut pas appuyer sur un bouton pour retrouver le code source d'origine. C'est tout l'enjeu du reverse : reconstruire la compréhension du programme à partir du binaire.

Mais un binaire laisse toujours des traces exploitables. Les textes affichés par le programme, les noms de fonctions système, parfois les noms de variables. C'est par là qu'on commence.

## Ghidra, l'analyse statique

Ghidra est un outil développé par la NSA, gratuit et public. Il fait deux choses.

Il **désassemble** : il traduit les instructions machine en assembleur, le langage lisible le plus proche du processeur. L'assembleur est précis mais aride, une instruction par ligne.

Il **décompile** : il va plus loin et reconstruit un pseudo-code proche du C, bien plus lisible. C'est la fonction qui t'intéresse. Au lieu de lire cinquante lignes d'assembleur, tu lis une dizaine de lignes qui ressemblent à du code normal.

Dans Ghidra, la fenêtre qui compte est la fenêtre Decompile. C'est là que s'affiche le pseudo-code. La fenêtre d'assembleur (Listing) sert de secours quand le décompilateur n'est pas clair.

### Ce que tu fais avec Ghidra

Tu l'utilises quand tu veux comprendre la logique d'un programme sans le lancer. Repérer une comparaison de mot de passe, comprendre un calcul, voir comment une décision est prise.

Le point de départ est toujours la fonction main. C'est le début de l'exécution d'un programme, la porte d'entrée. Quand tu veux comprendre ce que fait un binaire, tu ouvres main et tu lis.

### Les gestes de base dans Ghidra

- Importer un binaire : File, Import File, puis tu choisis le fichier
- Lancer l'analyse : réponds Yes à la question "Analyze", puis Analyze
- Aller dans main : fenêtre Symbol Tree à gauche, déplie Functions, double-clic sur main
- Ouvrir le décompilateur si besoin : menu Window, puis Decompile
- Renommer une variable : clic dessus, touche L, tape le nouveau nom

Renommer les variables au fur et à mesure rend le code de plus en plus lisible. Une variable nommée local_28 ne veut rien dire, mais si tu la renommes input quand tu comprends son rôle, la suite devient claire.

## gdb, l'analyse dynamique

gdb est un debugger. Son rôle d'origine est d'aider les développeurs à traquer les bugs en exécutant un programme pas à pas. On le détourne pour le reverse : on s'en sert pour observer et modifier un programme pendant qu'il tourne.

Avec gdb tu peux arrêter un programme à un endroit précis, regarder l'état de la mémoire et des registres à cet instant, puis reprendre, et même changer des valeurs au passage.

### pwndbg

gdb tout nu est austère. pwndbg est une surcouche qui l'enrichit : à chaque arrêt, il affiche les registres, la pile et le code autour de l'endroit où tu es, le tout en couleurs. Ça rend l'analyse bien plus lisible. On l'utilise systématiquement.

### Le vocabulaire de gdb

**Registre** : une petite case mémoire interne du processeur. Les registres portent des noms comme rax, rdi, rsi. Deux sont utiles à connaître. La valeur de retour d'une fonction (ce qu'elle renvoie) se range toujours dans rax. Les arguments passés à une fonction se rangent dans rdi (premier argument), rsi (deuxième argument).

**Breakpoint** (point d'arrêt) : un piège qu'on pose à un endroit du programme. Quand l'exécution l'atteint, elle s'arrête et te rend la main.

### Les commandes de base

- Poser un point d'arrêt sur une fonction : `break nom_fonction`
- Poser un point d'arrêt sur une adresse précise : `break *0xadresse`
- Lancer le programme : `run arguments`
- Laisser la fonction courante se terminer : `finish`
- Reprendre l'exécution : `continue`
- Changer la valeur d'un registre : `set $rax = 1`
- Lire une chaîne à une adresse : `x/s 0xadresse`
- Voir le code d'une fonction : `disassemble main`
- Quitter : `quit`

### Reconnaître ton code

Dans gdb, tu verras deux types d'adresses. Celles qui commencent par 0x40... sont ton programme. Celles qui commencent par 0x7ffff7... sont les bibliothèques système. Ce repère te sert tout le temps : quand tu cherches ton code, tu suis les 0x40...

## Statique ou dynamique, lequel choisir

Tu commences presque toujours par le plus simple, sans outil lourd : les commandes de reconnaissance (file, strings). Si ça ne suffit pas, tu passes à Ghidra pour lire la logique. Et quand lire ne suffit plus, quand tu veux agir sur le programme, tu passes à gdb.

| Tu veux | Outil |
|---|---|
| Voir le type d'un fichier et ses protections | file |
| Voir les textes lisibles dans un binaire | strings |
| Comprendre la logique sans lancer le programme | Ghidra |
| Observer ou modifier le programme pendant qu'il tourne | gdb |

La règle qui résume tout : on lit avant d'agir, et on agit seulement quand lire ne suffit plus.
