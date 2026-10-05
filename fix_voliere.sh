
set -euo pipefail
log(){ printf '\n\033[1;34m[*] %s\033[0m\n' "$*"; }
ok(){ printf '\033[1;32m[+] %s\033[0m\n' "$*"; }
fail(){ printf '\033[1;31m[!] %s\033[0m\n' "$*"; exit 1; }
[[ $EUID -eq 0 ]] || fail "A lancer en root : sudo bash fix_voliere.sh"
command -v gcc >/dev/null || fail "gcc absent sur la VM."

BUILD=/root/voliere_fix
rm -rf "$BUILD"; mkdir -p "$BUILD/src" "$BUILD/bin"

log "Compilation des verrous corriges"
cat > "$BUILD/src/verrou1.c" <<'EOF'
#include <stdio.h>
#include <string.h>
int main(int argc, char **argv){char*s="V0l13r3_S3cr3t_01";
 if(argc<2){printf("Usage: %s <mot_de_passe>\n",argv[0]);return 1;}
 if(strcmp(argv[1],s)==0){printf("Verrou 1 ouvert. Tu peux passer au compte suivant.\n");return 0;}
 printf("Acces refuse.\n");return 1;}
EOF
cat > "$BUILD/src/verrou2.c" <<'EOF'
#include <stdio.h>
#include <string.h>
int main(int argc, char **argv){char r[9];
 r[0]='C';r[1]='0';r[2]='r';r[3]='b';r[4]='3';r[5]='4';r[6]='u';r[7]='!';r[8]='\0';
 if(argc<2){printf("Usage: %s <mot_de_passe>\n",argv[0]);return 1;}
 int ok=1,i;for(i=0;i<8;i++){if(argv[1][i]!=r[i]){ok=0;break;}}
 if(ok&&argv[1][8]=='\0'){printf("Verrou 2 ouvert. Tu peux passer au compte suivant.\n");return 0;}
 printf("Non.\n");return 1;}
EOF
cat > "$BUILD/src/verrou3.c" <<'EOF'
#include <stdio.h>
#include <string.h>
int main(int argc, char **argv){unsigned char c[]={0x06,0x24,0x6B,0x17,0x2C,0x6E,0x0D,0x38,0x00};
 unsigned char k=0x5C;
 if(argc<2){printf("Usage: %s <cle>\n",argv[0]);return 1;}
 size_t l=strlen(argv[1]);if(l!=8){printf("Mauvaise longueur.\n");return 1;}
 int ok=1;for(size_t i=0;i<l;i++){if(((unsigned char)argv[1][i]^k)!=c[i]){ok=0;break;}}
 if(ok){printf("Verrou 3 ouvert. Tu peux passer au compte suivant.\n");return 0;}
 printf("Rate.\n");return 1;}
EOF
cat > "$BUILD/src/verrou4.c" <<'EOF'
#include <stdio.h>
#include <string.h>
int verifier(const char*s){return strcmp(s,"M0tDeP4sse_V4")==0;}
int main(int argc, char **argv){
 if(argc<2){printf("Usage: %s <mot_de_passe>\n",argv[0]);return 1;}
 if(verifier(argv[1])){printf("Verrou 4 ouvert. Tu peux passer au compte suivant.\n");return 0;}
 printf("Refuse. (Et si on changeait le saut ?)\n");return 1;}
EOF
cat > "$BUILD/src/verrou5.c" <<'EOF'
#include <stdio.h>
#include <string.h>
#include <sys/ptrace.h>
int main(int argc, char **argv){
 if(ptrace(PTRACE_TRACEME,0,0,0)==-1){printf("Surveillance detectee. Effacement.\n");return 1;}
 if(argc<2){printf("Usage: %s <mot_de_passe>\n",argv[0]);return 1;}
 if(strcmp(argv[1],"Bypass_Ptr4ce")==0){printf("Derniere protection levee.\n");
  printf("PREUVE FINALE  ->  FLAG{V0L13R3_D3M4NT3L33_2026}\n");printf("Enquete resolue.\n");return 0;}
 printf("Mauvais mot de passe.\n");return 1;}
EOF
for n in 1 2 3 4 5; do
  gcc -O0 -g -fno-stack-protector -no-pie -o "$BUILD/bin/verrou$n" "$BUILD/src/verrou$n.c"
done
ok "5 verrous recompiles"

log "Mise a jour des mots de passe des comptes"
echo "invite:V0l13r3_F0rum_2026"   | chpasswd
echo "operateur:V0l13r3_S3cr3t_01" | chpasswd
echo "archiviste:C0rb34u!"         | chpasswd
echo "analyste:Zx7Kp2Qd"           | chpasswd
echo "admin:M0tDeP4sse_V4"         | chpasswd
ok "Mots de passe des comptes mis a jour"

place(){ local user="$1" verrou="$2"
  cp "$BUILD/bin/$verrou" "/home/$user/mission/$verrou"
  chown "$user:$user" "/home/$user/mission/$verrou"
  chmod 750 "/home/$user/mission/$verrou"; }
log "Remplacement des binaires"
place invite verrou1; place operateur verrou2; place archiviste verrou3
place analyste verrou4; place admin verrou5
ok "Binaires remplaces"

log "Mise a jour de l'indice web (compte invite)"
WEBROOT=/var/www/voliere
if [[ -d "$WEBROOT/.interne" ]]; then
cat > "$WEBROOT/.interne/memo.txt" <<'EOF'
MEMO INTERNE - K0RB34U - ne pas diffuser
----------------------------------------
Le compte de secours 'invite' (SSH) est toujours actif.
Nouveau mot de passe : le nom "Voliere" en l33t speak
(a=4 e=3 i=1 o=0), majuscule gardee, suivi de "_F0rum_"
et de l'annee en cours (2026).
Exemple de la regle l33t : "Pirate" -> "P1r4t3".
Pensez a le changer. (toujours pas fait)
EOF
ok "Memo web mis a jour"
else
  echo "    (dossier web introuvable, indice invite a communiquer a l'oral : V0l13r3_F0rum_2026)"
fi

note(){ local user="$1" f="$2"; cat > "/home/$user/mission/$f"; chown "$user:$user" "/home/$user/mission/$f"; chmod 640 "/home/$user/mission/$f"; }
log "Mise a jour des notes"
note invite 00_BRIEF.txt <<'EOF'
==========================================================
  ENQUETE "LA VOLIERE"
==========================================================
Vous etes sur le serveur saisi de l'operateur K0RB34U.

Regle : le mot de passe de chaque compte EST la solution du
verrou que vous analysez. Pour passer au compte suivant, il
faut VRAIMENT resoudre le verrou. Les binaires ne donnent
plus la reponse.

Ici, 'verrou1'. Resolvez-le : la solution est aussi le mot
de passe du compte 'operateur'.
EOF
for pair in "operateur:01" "archiviste:02" "analyste:03" "admin:04"; do
  u="${pair%%:*}"; n="${pair##*:}"
  note "$u" "${n}_${u}.txt" <<EOF
Compte $u atteint.
Analysez le verrou de ce dossier. La solution que vous
trouvez est le mot de passe du compte suivant. Les binaires
n'affichent plus le mot de passe : trouvez-le par l'analyse.
EOF
done
ok "Notes mises a jour"

rm -rf "$BUILD/src"
log "Correctif v2 applique"
echo "    Toutes les valeurs ont change. Les anciens flags et mots de passe ne valent plus rien."
