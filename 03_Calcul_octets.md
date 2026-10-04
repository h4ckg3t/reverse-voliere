# Calculer les octets à la main

Un des verrous de l'enquête transforme ta saisie avant de la vérifier. Pour le résoudre, tu dois comprendre comment un caractère devient un octet, et comment inverser une transformation. Un outil peut le faire pour toi en une ligne, mais tu dois d'abord le faire à la main une fois. C'est la seule façon de vraiment comprendre ce qui se passe.

On va voir trois choses : comment un caractère devient un nombre, comment lire ce nombre en hexadécimal et en binaire, et comment fonctionne le XOR.

## Un caractère est un nombre

Dans un ordinateur, chaque caractère a un code. La lettre A vaut 65, la lettre B vaut 66, et ainsi de suite. C'est la table ASCII. Un texte n'est qu'une suite de ces codes.

Ce code tient sur un octet, c'est à dire 8 bits (8 chiffres binaires, des 0 et des 1).

## Trois façons d'écrire le même nombre

Le même octet peut s'écrire de trois manières. Prenons la lettre f.

- En décimal (base 10, comme on compte tous les jours) : 102
- En hexadécimal (base 16) : 0x66
- En binaire (base 2) : 01100110

Ce sont trois écritures du même nombre. Le 0x devant un nombre veut juste dire "ce qui suit est en hexadécimal".

## Hexadécimal vers binaire

C'est la conversion dont tu auras besoin. L'astuce qui simplifie tout : un chiffre hexadécimal correspond exactement à 4 bits. Un octet s'écrit avec 2 chiffres hexa, donc tu convertis chaque chiffre séparément en 4 bits, puis tu colles les deux groupes.

Pour convertir un chiffre hexa en 4 bits, les quatre positions valent 8, 4, 2, 1. Tu cherches quelles positions additionnées donnent ton chiffre.

Exemple avec le chiffre 6 : 6 = 4 + 2. Tu allumes les positions 4 et 2, tu éteins les autres.

```
position :  8 4 2 1
bit      :  0 1 1 0   donne 4+2 = 6
```

Donc 6 en hexa égale 0110 en binaire.

Pour l'octet complet 0x66, tu as deux fois le chiffre 6, donc 0110 puis 0110 :

```
0110 0110  =  01100110
```

### La table des 16 chiffres

Garde-la sous la main, tu convertis n'importe quel octet en deux coups d'oeil.

| Hexa | Binaire | Hexa | Binaire |
|---|---|---|---|
| 0 | 0000 | 8 | 1000 |
| 1 | 0001 | 9 | 1001 |
| 2 | 0010 | A | 1010 |
| 3 | 0011 | B | 1011 |
| 4 | 0100 | C | 1100 |
| 5 | 0101 | D | 1101 |
| 6 | 0110 | E | 1110 |
| 7 | 0111 | F | 1111 |

Rappel : A vaut 10, B vaut 11, C vaut 12, D vaut 13, E vaut 14, F vaut 15.

## Le XOR

Le XOR, ou "ou exclusif", est une opération sur les bits. Noté avec le symbole ^.

### La règle

Le XOR compare deux bits et répond à une seule question : sont-ils différents ? Si les deux bits sont différents, le résultat est 1. S'ils sont identiques, le résultat est 0.

| Bit A | Bit B | A XOR B |
|---|---|---|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

### Sur un octet entier

On applique la règle colonne par colonne. La lettre A (0x41) avec la clé 0x2A :

```
A    = 0 1 0 0 0 0 0 1   (0x41)
clé  = 0 0 1 0 1 0 1 0   (0x2A)
---------------------------  XOR colonne par colonne
       0 1 1 0 1 0 1 1   = 0x6B
```

Pour chaque colonne, bits identiques donnent 0, bits différents donnent 1.

### La propriété qui rend le XOR utile

Le XOR est son propre inverse. Si tu appliques la même clé deux fois, tu retrouves la valeur de départ.

```
résultat = 0 1 1 0 1 0 1 1   (0x6B)
clé      = 0 0 1 0 1 0 1 0   (0x2A)
---------------------------  XOR
           0 1 0 0 0 0 0 1   = 0x41 = A
```

Tu retrouves A. La même opération chiffre et déchiffre. C'est pour ça qu'on l'utilise pour masquer une donnée simplement.

En une phrase : donnée XOR clé donne le masqué, et masqué XOR clé redonne la donnée.

## Entraînement avant le verrou

Avant d'attaquer le verrou, entraîne-toi sur un mot connu. On prend "bonjour".

### Étape 1 : écris chaque lettre en hexadécimal

Sers-toi de la table ASCII (à ta disposition, ou avec la commande plus bas).

| Lettre | Hexa |
|---|---|
| b | 62 |
| o | 6F |
| n | 6E |
| j | 6A |
| o | 6F |
| u | 75 |
| r | 72 |

Vérifie toi-même sur ta machine :

```
echo -n "bonjour" | xxd -p
```

Tu dois obtenir 626f6e6a6f7572.

### Étape 2 : chiffre chaque octet avec une clé

Prends la clé 0x2A. Pour chaque octet, convertis en binaire, fais le XOR avec la clé, reconvertis.

Fais le premier à la main. b vaut 0x62 :

```
0x62 = 0 1 1 0 0 0 1 0
0x2A = 0 0 1 0 1 0 1 0
----------------------  XOR
       0 1 0 0 1 0 0 0  = 0x48 = 'H'
```

Le b chiffré devient H. Fais les six autres de la même façon.

### Étape 3 : déchiffre pour vérifier

Reprends chaque octet chiffré et réapplique la clé 0x2A. Tu dois retomber sur "bonjour". Si c'est le cas, tu as compris le mécanisme.

### Le raccourci avec Python

Une fois que tu as fait le calcul à la main, tu peux laisser la machine faire les répétitions. Chiffrer "bonjour" avec la clé 0x2A :

```
python3 -c "print(''.join(chr(ord(c) ^ 0x2A) for c in 'bonjour'))"
```

Déchiffrer se fait exactement pareil, puisque le XOR est son propre inverse. Tu réappliques la même clé sur le résultat.

## Le piège à connaitre

Quand tu lis des octets dans un outil, tu verras parfois une notation comme \x1b. Ce n'est pas quatre caractères (\, x, 1, b). C'est un seul octet, de valeur 1B en hexadécimal. Le \x veut dire "ce qui suit est de l'hexa brut". Tu écris donc 1B et tu passes au suivant. Si tu le comptes comme plusieurs caractères, tout ton calcul se décale.

Maintenant tu as tout pour attaquer le verrou qui transforme ta saisie. Tu vas y retrouver exactement ces étapes : une table d'octets chiffrés, une clé, et le XOR à inverser.
