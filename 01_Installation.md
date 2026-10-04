# Installation de l'environnement

Pour mener l'enquête, il te faut deux machines virtuelles sous VMware : la cible (le serveur à analyser) et ton attaquant (ton Kali, ta machine de travail).

La cible, tu ne l'installes pas toi-même, elle est déjà prête. Tu la récupères sous forme d'image à importer. Ton attaquant Kali, tu l'as déjà ou tu l'installes de ton côté.

Compte environ 20 minutes pour tout mettre en place.

## Ce qu'il te faut

- VMware Workstation installé
- Une VM Kali (ta machine attaquante), avec au moins 4 Go de RAM alloués (Ghidra est gourmand)
- La VM cible, à récupérer via le lien communiqué en début de séance

## À préparer avant la séance

Pour ne pas perdre de temps le jour J, fais ça en amont :

- Installe VMware et ta VM Kali si ce n'est pas déjà fait
- Télécharge le zip de la VM cible à l'avance (il fait plusieurs Go, autant ne pas saturer le réseau de la salle en le téléchargeant à 15 en même temps)
- Vérifie que ta VM Kali a au moins 4 Go de RAM pour que Ghidra tourne correctement

## Partie 1 : récupérer la VM cible

La machine cible est fournie sous forme d'une image VMware (format OVF). Le lien de téléchargement est communiqué en début de séance.

L'image est faite de trois fichiers :

- voliere-cible.ovf
- voliere-cible-disk1.vmdk
- voliere-cible.mf

### Règle à respecter absolument

Les trois fichiers vont ensemble. Tu les gardes dans un même dossier, tu n'en déplaces aucun, tu n'en renommes aucun.

Le .ovf est le plan de la machine, le .vmdk est son disque dur, le .mf sert à vérifier l'intégrité. Au moment de l'import, VMware lit le .ovf puis va chercher les deux autres à côté. Si l'un des trois manque ou a été déplacé, l'import échoue.

### Marche à suivre

1. Télécharge le fichier zip depuis le lien.
2. Décompresse le zip. Tu obtiens un dossier VM voliere-cible qui contient les trois fichiers.
3. Dans VMware, menu File puis Open.
4. Sélectionne le fichier voliere-cible.ovf dans ce dossier.
5. VMware demande un nom et un emplacement pour la VM, valide.
6. L'import se lance, il reconstruit la machine à partir des trois fichiers.

Une fois l'import terminé, la cible apparaît dans ta bibliothèque VMware. Tu peux la démarrer.

## Partie 2 : récupérer l'adresse IP de la cible

Démarre la VM cible. Tu n'as pas besoin de te connecter dessus directement, tu vas l'attaquer depuis ton Kali. Mais il te faut son adresse IP.

Le plus simple, scanne le réseau depuis ton Kali pour la trouver (voir la reconnaissance plus bas), ou lis-la sur l'écran de la cible. Si tu te connectes à la cible pour la lire, la commande est :

```
ip a
```

Repère l'adresse en face de inet pour l'interface réseau (ens33 ou similaire), du type 192.168.x.x. C'est l'adresse de ta cible, note-la, tu vas t'en servir tout le temps.

## Partie 3 : préparer la machine attaquante

Ta VM Kali est ta machine de travail. Vérifie qu'elle a les outils dont tu auras besoin :

```
sudo apt update
sudo apt install -y gdb file ltrace strace xxd python3 ghidra nmap
```

Installe pwndbg, une surcouche de gdb qui rend l'analyse bien plus lisible :

```
mkdir -p ~/tools && cd ~/tools
git clone https://github.com/pwndbg/pwndbg
cd pwndbg
./setup.sh
```

### Vérifier que Kali voit la cible

Point important : tes deux VM (la cible et ton Kali) doivent être sur le même réseau NAT dans VMware pour communiquer. Vérifie dans les paramètres réseau de chaque VM que la carte est bien en NAT. Si l'une est en NAT et l'autre en autre chose, elles ne se verront pas, et ni le ssh ni le scp ne marcheront.

Ce réseau NAT est local à ton PC, il ne dépend pas de ta connexion internet ni du wifi. Tes deux VM se voient entre elles même sans internet.

Prépare aussi ton dossier de travail sur Kali, tu y déposeras les binaires à analyser :

```
mkdir -p ~/re_lab
```

Puis teste l'accès à la cible (remplace par l'IP que tu as trouvée) :

```
ping -c 2 192.168.x.x
```

Si ça répond, tes deux machines communiquent. Tu es prêt à mener l'enquête.

## Partie 4 : les manipulations de base

Pendant le TP, tu feras tout le temps les mêmes gestes. Les voici.

### Reconnaissance réseau

```
nmap -sV 192.168.x.x
```

Montre les services ouverts sur la cible et leur version.

### Se connecter à la cible en SSH

```
ssh invite@192.168.x.x
```

La première connexion demande de confirmer l'empreinte, tape yes. Puis le mot de passe.

### Rapatrier un fichier de la cible vers Kali

Les binaires à analyser sont sur la cible, mais Ghidra est sur ton Kali. Il faut donc copier le binaire vers Kali. La commande scp fait ça :

```
scp compte@192.168.x.x:/chemin/du/fichier ~/re_lab/
```

Par exemple, pour rapatrier un verrou depuis le compte operateur :

```
scp operateur@192.168.x.x:/home/operateur/mission/verrou2 ~/re_lab/
```

Il demande le mot de passe du compte, puis dépose le fichier dans ton dossier re_lab sur Kali.

### Lire un fichier sur place

```
cat nom_du_fichier
```

Ne fais jamais cat sur un binaire (un exécutable), ça remplit le terminal de caractères illisibles. cat sert pour les fichiers texte, comme les notes de mission.

## Les pièges classiques

Je ne peux pas lire un fichier, permission denied. Tu n'es pas dans le bon compte, ou pas dans ton dossier. Après un su, fais toujours cd ~/mission pour aller dans ton répertoire. Chaque compte ne peut lire que ses propres fichiers.

command not found quand je lance un programme. Pour exécuter un programme du dossier courant, mets ./ devant son nom. Exemple : ./verrou1 et non verrou1.

Le mot de passe ne passe pas en SSH ou en scp. Tu le tapes en aveugle, et les mots de passe de l'enquête contiennent des pièges (des 0 à la place des O, des 3 à la place des E). Tape lentement et vérifie chaque caractère.

Mon terminal affiche n'importe quoi après un cat sur un binaire. Tape reset puis Entrée, l'affichage revient à la normale.

L'import de la VM échoue. Vérifie que les trois fichiers (.ovf, .vmdk, .mf) sont bien ensemble dans le même dossier, et que tu as sélectionné le .ovf au moment du Open.
