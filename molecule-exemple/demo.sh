#!/bin/bash
# 🎬 Script de démonstration Molecule
# Ce script guide à travers les étapes de Molecule avec des explications

set -e

# Couleurs pour le terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour afficher et attendre
show_step() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo ""
    if [ "$2" != "skip_wait" ]; then
        read -p "Appuyez sur Entrée pour continuer..."
    fi
}

# Fonction pour exécuter une commande avec explication
run_cmd() {
    echo -e "${YELLOW}> $1${NC}"
    echo ""
    eval "$1"
    echo ""
}

# Vérifier qu'on est dans le bon répertoire
cd "$(dirname "$0")/nginx-simple"

# Intro
clear
echo -e "${GREEN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║          🧪  DÉMONSTRATION ANSIBLE MOLECULE  🧪               ║
║                                                               ║
║     Ce script va vous guider à travers un test Molecule      ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""
echo "Nous allons tester un rôle qui installe nginx"
echo ""
read -p "Appuyez sur Entrée pour commencer..."

# Étape 1 : Montrer la structure
show_step "📁 ÉTAPE 1 : Structure du projet"
run_cmd "tree -L 3 ."

show_step "🔧 ÉTAPE 2 : Configuration Molecule (molecule.yml)" "skip_wait"
echo "Ce fichier définit :"
echo "  • Sur quel OS tester (Ubuntu 22.04)"
echo "  • Comment créer l'environnement (Docker)"
echo ""
read -p "Appuyez sur Entrée pour voir le fichier..."
run_cmd "cat molecule/default/molecule.yml"

show_step "🎯 ÉTAPE 3 : Playbook d'application (converge.yml)" "skip_wait"
echo "Ce fichier dit comment appliquer le rôle"
echo ""
read -p "Appuyez sur Entrée pour voir le fichier..."
run_cmd "cat molecule/default/converge.yml"

show_step "✅ ÉTAPE 4 : Tests de vérification (verify.yml)" "skip_wait"
echo "Ce fichier contient tous les tests à exécuter"
echo ""
read -p "Appuyez sur Entrée pour voir le fichier..."
run_cmd "cat molecule/default/verify.yml"

show_step "🐳 ÉTAPE 5 : Créer l'environnement de test"
echo "Molecule va créer un conteneur Docker avec Ubuntu"
echo ""
run_cmd "molecule create"

show_step "📋 ÉTAPE 6 : Vérifier que le conteneur existe"
run_cmd "molecule list"

show_step "🚀 ÉTAPE 7 : Appliquer le rôle (converge)"
echo "Molecule va installer et configurer nginx"
echo ""
run_cmd "molecule converge"

show_step "🔍 ÉTAPE 8 : Se connecter au conteneur" "skip_wait"
echo "Vous pouvez maintenant explorer le conteneur"
echo ""
echo "Essayez ces commandes une fois connecté :"
echo "  • curl localhost          (voir la page nginx)"
echo "  • systemctl status nginx  (vérifier le service)"
echo "  • cat /var/www/html/index.html"
echo "  • exit                    (pour sortir)"
echo ""
read -p "Appuyez sur Entrée pour vous connecter..."
molecule login || true

show_step "✅ ÉTAPE 9 : Lancer les tests (verify)"
echo "Molecule va vérifier que tout fonctionne"
echo ""
run_cmd "molecule verify"

show_step "🗑️  ÉTAPE 10 : Nettoyer (destroy)"
echo "Molecule va supprimer le conteneur"
echo ""
run_cmd "molecule destroy"

# Conclusion
clear
echo -e "${GREEN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║                  ✅  DÉMONSTRATION TERMINÉE  ✅               ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""
echo "🎉 Félicitations ! Vous avez vu toutes les étapes de Molecule"
echo ""
echo "Pour refaire tout le cycle automatiquement :"
echo -e "${YELLOW}  molecule test${NC}"
echo ""
echo "Pour plus d'informations :"
echo "  • README.md (dans ce dossier)"
echo "  • QUICK_START.md (guide rapide)"
echo "  • EXPLICATION_SIMPLE.md (concepts détaillés)"
echo ""

