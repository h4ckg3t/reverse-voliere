# Aide-mémoire des commandes

Toutes les commandes dont tu auras besoin pendant l'enquête, regroupées. Garde cette page ouverte à côté de toi.

## Reconnaissance d'un fichier

```
file nom_du_fichier
```
Donne le type du fichier et ses protections.

```
strings nom_du_fichier
```
Affiche toutes les chaînes de caractères lisibles contenues dans le fichier. Souvent suffisant pour trouver un texte caché.

```
ltrace ./nom_du_fichier argument
```
Affiche les appels de bibliothèque faits par le programme pendant qu'il tourne.

## Se déplacer et lire

```
cd ~/mission
```
Va dans ton dossier mission. Le ~ désigne toujours le dossier du compte où tu es.

```
ls -l
```
Liste les fichiers avec leurs permissions et leur propriétaire.

```
cat nom_du_fichier
```
Affiche le contenu d'un fichier texte. Jamais sur un binaire.

```
whoami
```
Affiche sous quel compte tu es.

```
pwd
```
Affiche dans quel dossier tu te trouves.

## Changer de compte

```
su nom_du_compte
```
Bascule sur un autre compte. Demande son mot de passe. Après un su, pense toujours à faire cd ~/mission pour aller dans ton nouveau dossier.

## Réseau et transfert

```
ip a
```
Affiche l'adresse IP de la machine.

```
ping -c 2 192.168.x.x
```
Teste si une machine répond sur le réseau.

```
ssh compte@192.168.x.x
```
Se connecte à distance sur une machine.

```
scp compte@192.168.x.x:/chemin/fichier ~/re_lab/
```
Copie un fichier d'une machine distante vers ton dossier local re_lab.

## Exécuter un binaire

```
./nom_du_binaire argument
```
Lance un programme du dossier courant. Le ./ est obligatoire, sinon le shell ne trouve pas le programme.

## Conversion et calcul

```
echo -n "texte" | xxd -p
```
Convertit un texte en hexadécimal.

```
echo -n "616263" | xxd -r -p
```
Convertit de l'hexadécimal vers le texte.

```
python3 -c "print(format(0x66, '08b'))"
```
Affiche un nombre en binaire sur 8 bits.

```
python3 -c "print(hex(0x66 ^ 0x2A))"
```
Fait un XOR entre deux octets.

```
python3 -c "print(''.join(chr(c ^ 0x2A) for c in [0x66,0x5B,0x58]))"
```
Déchiffre une liste d'octets par XOR avec une clé.

## Ghidra

| Action | Comment |
|---|---|
| Importer un binaire | File, Import File |
| Lancer l'analyse | Yes à "Analyze", puis Analyze |
| Ouvrir main | Symbol Tree, Functions, double-clic sur main |
| Ouvrir le décompilateur | Window, Decompile |
| Renommer une variable | clic dessus, touche L |

## gdb avec pwndbg

| Action | Commande |
|---|---|
| Lancer gdb sur un binaire | `gdb ./binaire` |
| Point d'arrêt sur une fonction | `break nom_fonction` |
| Point d'arrêt sur une adresse | `break *0x401229` |
| Lancer avec un argument | `run argument` |
| Finir la fonction en cours | `finish` |
| Reprendre | `continue` |
| Changer un registre | `set $rax = 1` |
| Lire une chaîne à une adresse | `x/s 0x402045` |
| Voir le code d'une fonction | `disassemble main` |
| Quitter | `quit` |

## Débloquer les situations

| Problème | Solution |
|---|---|
| permission denied sur un fichier | Mauvais compte ou mauvais dossier. Fais su puis cd ~/mission |
| command not found | Mets ./ devant le nom du binaire |
| Le terminal affiche n'importe quoi | Tape reset puis Entrée |
| Un guillemet bloque la ligne (>) | Tape Ctrl+C |
| Le mot de passe est refusé | Tape lentement, attention aux 0 et aux 3 |
