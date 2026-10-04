# Installation de l'environnement

Avant de commencer l'enquête, tu dois monter ton laboratoire. Il te faut deux machines virtuelles sous VMware : une cible (le serveur à analyser) et un attaquant (ton Kali, ta machine de travail).

Compte environ 45 minutes pour tout mettre en place. Suis les étapes dans l'ordre, ne saute rien.

## Ce qu'il te faut

- VMware Workstation installé
- L'ISO d'Ubuntu Server 24.04 LTS (environ 3 Go), à télécharger sur https://ubuntu.com/download/server
- Une VM Kali (ta machine attaquante), que tu as déjà ou que tu installes à part

## Partie 1 : créer la VM cible

### Créer la machine

Dans VMware, nouvelle machine virtuelle. Pointe vers l'ISO Ubuntu Server que tu as téléchargé. Règle :

- Disque : 20 Go
- Mémoire : 4 Go
- Processeurs : 2
- Réseau : NAT (laisse par défaut)

Démarre la VM, elle boote sur l'ISO et lance l'installateur Ubuntu. Toute l'installation se fait au clavier, pas de souris. Flèches pour naviguer, Entrée pour valider, barre d'espace pour cocher.

### Dérouler l'installation

La plupart des écrans se valident par défaut. Trois écrans demandent de l'attention, les voici.

**Écran proxy.** Laisse le champ vide et valide avec Terminé. Tu n'as pas de proxy chez toi, cet écran ne te concerne pas.

**Écran partitionnement (Guided storage configuration).** Laisse les options par défaut, utilise le disque entier. Valide, puis confirme malgré l'avertissement de formatage. C'est le disque virtuel de 20 Go qui se formate, rien sur ton PC n'est touché.

**Écran SSH Setup.** Coche "Install OpenSSH server" avec la barre d'espace. Un [X] doit apparaître dans la case. C'est le point le plus important de toute l'installation. Sans SSH, rien ne marchera ensuite.

Pour le reste : choisis ton nom, un nom de serveur (par exemple voliere), un identifiant et un mot de passe. Note-les, c'est ton compte admin. Sur l'écran des logiciels optionnels (Featured server snaps), ne coche rien.

Laisse l'installation se terminer, puis redémarre quand il le propose.

### Récupérer l'adresse IP

Une fois Ubuntu redémarré, connecte-toi avec ton identifiant et ton mot de passe (le mot de passe ne s'affiche pas quand tu le tapes, c'est normal).

Récupère l'adresse IP de la VM :

```
ip a
```

Repère la ligne de l'interface réseau (ens33 ou similaire) et l'adresse en face de inet, du type 192.168.x.x. Note-la. C'est l'adresse de ta cible, tu vas t'en servir tout le temps.

## Partie 2 : provisionner la cible

La cible est installée mais vide. Un script va la transformer en serveur de l'enquête : créer les comptes, poser les verrous, monter le service web.

### Récupérer le script

Le script est sur le dépôt du TP. Sur ta VM cible, télécharge-le :

```
wget https://raw.githubusercontent.com/h4ckg3t/reverse-voliere/main/provision_ctf.sh
```

### Lancer le script

```
sudo bash provision_ctf.sh
```

Il installe les outils, compile les verrous et met tout en place. Quelques minutes. À la fin il affiche un récapitulatif avec l'adresse de la cible. Si tout est vert, ta cible est prête.

## Partie 3 : préparer la machine attaquante

Ta VM Kali est ta machine de travail. Vérifie qu'elle a les outils dont tu auras besoin :

```
sudo apt update
sudo apt install -y gdb file ltrace strace xxd python3 ghidra
```

Installe pwndbg, une surcouche de gdb qui rend l'analyse bien plus lisible :

```
mkdir -p ~/tools && cd ~/tools
git clone https://github.com/pwndbg/pwndbg
cd pwndbg
./setup.sh
```

### Vérifier que Kali voit la cible

Les deux VM doivent être sur le même réseau NAT dans VMware pour se voir. Depuis Kali, teste l'accès à la cible (remplace par l'IP que tu as notée) :

```
ping -c 2 192.168.x.x
```

Si ça répond, tes deux machines communiquent. Tu es prêt.

## Partie 4 : les manipulations de base

Pendant le TP, tu feras tout le temps les mêmes gestes. Les voici.

### Se connecter à la cible en SSH

```
ssh invite@192.168.x.x
```

La première connexion demande de confirmer l'empreinte, tape yes. Puis le mot de passe.

### Rapatrier un fichier de la cible vers Kali

Les binaires à analyser sont sur la cible, mais Ghidra est sur ton Kali. Il faut donc copier le binaire vers Kali. La commande scp fait ça :

```
scp utilisateur@192.168.x.x:/chemin/du/fichier ~/re_lab/
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

Attention, ne fais jamais cat sur un binaire (un exécutable), ça remplit le terminal de caractères illisibles. cat sert pour les fichiers texte, comme les notes de mission.

## Les pièges classiques

**Je ne peux pas lire un fichier, permission denied.** Tu n'es pas dans le bon compte, ou tu n'es pas dans ton dossier. Après un su, fais toujours cd ~/mission pour aller dans ton répertoire. Chaque compte ne peut lire que ses propres fichiers.

**command not found quand je lance un programme.** Pour exécuter un programme du dossier courant, mets ./ devant son nom. Exemple : ./verrou1 et non verrou1.

**Le mot de passe ne passe pas en SSH ou en scp.** Tu le tapes en aveugle, et les mots de passe de l'enquête contiennent des pièges (des 0 à la place des O, des 3 à la place des E). Tape lentement et vérifie chaque caractère.

**Mon terminal affiche n'importe quoi après un cat sur un binaire.** Tape reset puis Entrée, l'affichage revient à la normale.
