#!/usr/bin/env bash
# =============================================================================
#  Provisioning de la VM cible  -  CTF "La Voliere"
#  TP reverse engineering, Mastere 2, 5 et 6 octobre 2026
#
#  A LANCER EN ROOT sur une VM Ubuntu/Debian FRAICHE et JETABLE.
#  Usage : sudo bash provision_ctf.sh
#
#  Construit : service SSH + facade web avec indice, chaine de 5 comptes
#  dont les mots de passe se recuperent en resolvant les 5 binaires.
#  Idempotent : relançable sans tout casser.
# =============================================================================
set -euo pipefail

log()  { printf '\n\033[1;34m[*] %s\033[0m\n' "$*"; }
ok()   { printf '\033[1;32m[+] %s\033[0m\n' "$*"; }
fail() { printf '\033[1;31m[!] %s\033[0m\n' "$*"; exit 1; }

[[ $EUID -eq 0 ]]              || fail "A lancer en root (sudo bash provision_ctf.sh)."
command -v apt-get >/dev/null  || fail "Prevu pour Ubuntu/Debian (apt)."

# --- Parametres de la chaine (MODIFIABLES si tu veux changer les secrets) ---
FOOTHOLD_USER="invite"
FOOTHOLD_PASS="V0l13r3_2026"               # derivable depuis l'indice web
declare -A CHAIN=(
  [operateur]="C0rb34u_pr3nd_s0n_3nv0l"
  [archiviste]="L3s_b0ucl3s_n3_m3nt3nt_pas"
  [analyste]="X0R_c_3st_pas_du_chiffr3m3nt"
  [admin]="Sautez_l3_c0ntr0l3"
)
BUILD=/root/voliere_build
WEBROOT=/var/www/voliere

# ---------------------------------------------------------------------------
log "Installation des paquets (sshd, gcc, python3)"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq openssh-server gcc python3
ok "Paquets installes"

# ---------------------------------------------------------------------------
log "Compilation des 5 verrous"
rm -rf "$BUILD"; mkdir -p "$BUILD/src" "$BUILD/bin"

cat > "$BUILD/src/verrou1.c" <<'EOF'
#include <stdio.h>
#include <string.h>
int main(int argc, char **argv){char*s="k0rb34u_adm1n_2026";
 if(argc<2){printf("Usage: %s <mot_de_passe>\n",argv[0]);return 1;}
 if(strcmp(argv[1],s)==0){printf("Journal deverrouille.\n");
  printf("Identifiant retrouve  ->  operateur : C0rb34u_pr3nd_s0n_3nv0l\n");return 0;}
 printf("Acces refuse.\n");return 1;}
EOF
cat > "$BUILD/src/verrou2.c" <<'EOF'
#include <stdio.h>
#include <string.h>
int main(int argc, char **argv){char r[9];
 r[0]='H';r[1]='4';r[2]='c';r[3]='k';r[4]='L';r[5]='4';r[6]='b';r[7]='!';r[8]='\0';
 if(argc<2){printf("Usage: %s <mot_de_passe>\n",argv[0]);return 1;}
 int ok=1,i;for(i=0;i<8;i++){if(argv[1][i]!=r[i]){ok=0;break;}}
 if(ok&&argv[1][8]=='\0'){printf("Coffre ouvert.\n");
  printf("Identifiant retrouve  ->  archiviste : L3s_b0ucl3s_n3_m3nt3nt_pas\n");return 0;}
 printf("Non.\n");return 1;}
EOF
cat > "$BUILD/src/verrou3.c" <<'EOF'
#include <stdio.h>
#include <string.h>
int main(int argc, char **argv){unsigned char c[]={0x66,0x5B,0x58,0x1B,0x44,0x5F,0x59,0x44,0x00};
 unsigned char k=0x2A;
 if(argc<2){printf("Usage: %s <cle>\n",argv[0]);return 1;}
 size_t l=strlen(argv[1]);if(l!=8){printf("Mauvaise longueur.\n");return 1;}
 int ok=1;for(size_t i=0;i<l;i++){if(((unsigned char)argv[1][i]^k)!=c[i]){ok=0;break;}}
 if(ok){printf("Archive dechiffree.\n");
  printf("Identifiant retrouve  ->  analyste : X0R_c_3st_pas_du_chiffr3m3nt\n");return 0;}
 printf("Rate.\n");return 1;}
EOF
cat > "$BUILD/src/verrou4.c" <<'EOF'
#include <stdio.h>
#include <string.h>
int verifier(const char*s){return strcmp(s,"Tr0ub4dour")==0;}
int main(int argc, char **argv){
 if(argc<2){printf("Usage: %s <mot_de_passe>\n",argv[0]);return 1;}
 if(verifier(argv[1])){printf("Console administrateur ouverte.\n");
  printf("Identifiant retrouve  ->  admin : Sautez_l3_c0ntr0l3\n");return 0;}
 printf("Refuse. (Et si on changeait le saut ?)\n");return 1;}
EOF
cat > "$BUILD/src/verrou5.c" <<'EOF'
#include <stdio.h>
#include <string.h>
#include <sys/ptrace.h>
int main(int argc, char **argv){
 if(ptrace(PTRACE_TRACEME,0,0,0)==-1){printf("Surveillance detectee. Effacement.\n");return 1;}
 if(argc<2){printf("Usage: %s <mot_de_passe>\n",argv[0]);return 1;}
 if(strcmp(argv[1],"N0D3buG")==0){printf("Derniere protection levee.\n");
  printf("PREUVE FINALE  ->  FLAG{K0RB34U_D3M4SQU3_2026}\n");
  printf("Enquete resolue. L'operateur de la Voliere est identifie.\n");return 0;}
 printf("Mauvais mot de passe.\n");return 1;}
EOF

for n in 1 2 3 4 5; do
  gcc -O0 -g -fno-stack-protector -no-pie -o "$BUILD/bin/verrou$n" "$BUILD/src/verrou$n.c"
done
ok "5 verrous compiles"

# ---------------------------------------------------------------------------
# Fonction utilitaire : cree un user, pose mot de passe, home 700
make_user() {
  local user="$1" pass="$2"
  id "$user" &>/dev/null || useradd -m -s /bin/bash "$user"
  echo "$user:$pass" | chpasswd
  mkdir -p "/home/$user/mission"
  chmod 700 "/home/$user"
}

log "Creation de la chaine de comptes"
make_user "$FOOTHOLD_USER" "$FOOTHOLD_PASS"
for u in operateur archiviste analyste admin; do
  make_user "$u" "${CHAIN[$u]}"
done
ok "Comptes crees : $FOOTHOLD_USER, operateur, archiviste, analyste, admin"

# ---------------------------------------------------------------------------
# Placement des verrous et des notes de mission, etape par etape
place() {   # place <user> <verrou_src> <nom_affiche>
  local user="$1" verrou="$2" nom="$3"
  cp "$BUILD/bin/$verrou" "/home/$user/mission/$nom"
  chown "$user:$user" "/home/$user/mission/$nom"
  chmod 750 "/home/$user/mission/$nom"
}

note() {    # note <user> <fichier> <<< contenu
  local user="$1" f="$2"; shift 2
  cat > "/home/$user/mission/$f"
  chown "$user:$user" "/home/$user/mission/$f"
  chmod 640 "/home/$user/mission/$f"
}

log "Placement des missions"

# --- invite : brief + verrou1 ---
place "$FOOTHOLD_USER" verrou1 verrou1
note "$FOOTHOLD_USER" "00_BRIEF.txt" <<'EOF'
==========================================================
  ENQUETE "LA VOLIERE"  -  acces initial reussi
==========================================================
Vous etes sur le serveur saisi de l'operateur K0RB34U, qui
gerait un forum de revente de donnees volees, "la Voliere".

Votre mission : remonter la chaine des comptes du serveur
jusqu'a prouver l'identite de l'operateur. Chaque compte est
protege par un "verrou" logiciel laisse par K0RB34U. En
analysant chaque verrou, vous retrouvez l'identifiant du
compte suivant.

Ici, dans ~/mission, se trouve 'verrou1'. Analysez-le pour
obtenir l'acces au compte 'operateur'.

Rappel : vous n'avez pas le code source des verrous. A vous
de retrouver ce qu'ils cachent.
EOF

# --- operateur : note + verrou2 ---
place operateur verrou2 verrou2
note operateur "01_operateur.txt" <<'EOF'
Compte operateur atteint.
K0RB34U notait ici les acces au coffre d'archives.
'verrou2' garde l'identifiant du compte 'archiviste'.
Le mot de passe n'apparait plus en clair : il faudra lire
ce que fait reellement le programme.
EOF

# --- archiviste : note + verrou3 ---
place archiviste verrou3 verrou3
note archiviste "02_archiviste.txt" <<'EOF'
Compte archiviste atteint.
Les archives volees etaient "brouillees" avant stockage.
'verrou3' protege l'acces du compte 'analyste'. La cle fait
8 caracteres et votre saisie est transformee avant d'etre
verifiee. A vous de remonter la transformation.
EOF

# --- analyste : note + verrou4 ---
place analyste verrou4 verrou4
note analyste "03_analyste.txt" <<'EOF'
Compte analyste atteint.
Plus besoin de deviner le secret : il suffit parfois de
faire croire au programme qu'on l'a donne.
'verrou4' garde la console 'admin'. Ouvrez-la.
EOF

# --- admin : note + verrou5 ---
place admin verrou5 verrou5
note admin "04_admin.txt" <<'EOF'
Compte admin atteint, vous touchez au but.
Le dernier verrou se mefie des analystes : lance sous
surveillance, il s'efface. Dejouez sa defense pour extraire
la PREUVE FINALE qui identifie K0RB34U et clot l'enquete.
EOF
ok "Missions placees"

# ---------------------------------------------------------------------------
log "Mise en place de la facade web (indice d'acces initial)"
mkdir -p "$WEBROOT/.interne"
cat > "$WEBROOT/index.html" <<'EOF'
<!doctype html><html lang="fr"><head><meta charset="utf-8">
<title>La Voliere</title></head><body style="background:#111;color:#3c3;font-family:monospace">
<h1>~ La Voliere ~</h1>
<p>Acces reserve aux membres. Le forum est hors ligne pour maintenance.</p>
<!-- memo interne deplace dans /.interne/memo.txt -->
</body></html>
EOF
cat > "$WEBROOT/.interne/memo.txt" <<'EOF'
MEMO INTERNE - K0RB34U - ne pas diffuser
----------------------------------------
Le compte de secours 'invite' (SSH) est toujours actif.
Comme d'habitude, mot de passe = le nom "Voliere" ecrit en
l33t speak (a=4 e=3 i=1 o=0), majuscule initiale conservee,
suivi d'un underscore et de l'annee en cours (2026).
Exemple de la regle sur un autre mot : "Pirate" -> "P1r4t3".
Pensez a le changer. (pas fait)
EOF
cat > "$WEBROOT/robots.txt" <<'EOF'
User-agent: *
Disallow: /.interne/
EOF
chmod -R 755 "$WEBROOT"

cat > /etc/systemd/system/voliere-web.service <<EOF
[Unit]
Description=Facade web CTF Voliere
After=network.target
[Service]
ExecStart=/usr/bin/python3 -m http.server 80 --directory $WEBROOT
Restart=always
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now voliere-web.service
ok "Facade web active sur le port 80"

# ---------------------------------------------------------------------------
log "Configuration SSH (authentification par mot de passe)"
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
# bloquer la connexion directe en root (ils doivent passer par la chaine)
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl enable --now ssh 2>/dev/null || systemctl enable --now sshd
systemctl restart ssh 2>/dev/null || systemctl restart sshd
ok "SSH configure"

# ---------------------------------------------------------------------------
# Nettoyage des sources de build (les etudiants ne doivent pas les trouver)
rm -rf "$BUILD/src"

IP=$(hostname -I | awk '{print $1}')
log "Provisioning termine"
echo "    Cible prete. IP de la VM : ${IP:-a_verifier}"
echo "    Port 80 (indice) et port 22 (SSH) ouverts."
echo "    Point d'entree : compte '$FOOTHOLD_USER' via l'indice web."
echo
echo "    Pense a exporter cette VM en OVA pour la distribuer aux binomes."
echo "    Pour reinitialiser une partie : relance ce script (idempotent)."
