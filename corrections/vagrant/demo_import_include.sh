#!/bin/bash

# ============================================================================
# Script de Démonstration : import_tasks vs include_tasks
# ============================================================================
#
# Usage : ./demo_import_include.sh
#
# Ce script permet de lancer facilement toutes les démonstrations
# pour vos cours sur les différences entre import_tasks et include_tasks
#
# ============================================================================

set -e  # Arrêter en cas d'erreur (sauf où on gère les erreurs)

# Couleurs pour un affichage clair
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Fonction pour afficher un titre
print_title() {
    echo ""
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD} $1${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Fonction pour afficher un sous-titre
print_subtitle() {
    echo ""
    echo -e "${MAGENTA}▶ $1${NC}"
    echo ""
}

# Fonction pour demander confirmation
confirm() {
    echo -e "${YELLOW}$1 [Entrée pour continuer, Ctrl+C pour quitter]${NC}"
    read -r
}

# Fonction pour afficher un succès
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Fonction pour afficher une erreur attendue
print_expected_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Fonction pour afficher une information
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Vérifier qu'on est dans le bon répertoire
if [ ! -f "exemple_echec_import.yml" ]; then
    echo -e "${RED}Erreur : Les fichiers de démonstration ne sont pas trouvés.${NC}"
    echo "Assurez-vous d'être dans le répertoire corrections/vagrant/"
    exit 1
fi

# Vérifier qu'Ansible est installé
if ! command -v ansible-playbook &> /dev/null; then
    echo -e "${RED}Erreur : ansible-playbook n'est pas installé.${NC}"
    echo "Installez Ansible avec : pip install ansible"
    exit 1
fi

clear

print_title "🎓 DÉMONSTRATION : import_tasks vs include_tasks"

echo -e "${BOLD}Bienvenue dans la démonstration interactive !${NC}"
echo ""
echo "Ce script va vous guider à travers 3 démonstrations :"
echo "  1. ${RED}ÉCHEC${NC} avec import_tasks (variable dynamique)"
echo "  2. ${GREEN}SUCCÈS${NC} avec include_tasks (variable dynamique)"
echo "  3. ${BLUE}COMPARAISON${NC} des tags et visibilité"
echo ""

confirm "Prêt à commencer ?"

# ============================================================================
# DÉMONSTRATION 1 : ÉCHEC avec import_tasks
# ============================================================================

print_title "🔴 DÉMONSTRATION 1 : ÉCHEC avec import_tasks"

echo -e "${BOLD}Objectif pédagogique :${NC}"
echo "Montrer qu'on ne peut PAS utiliser une variable définie dynamiquement"
echo "dans le nom du fichier avec import_tasks."
echo ""
echo -e "${BOLD}Ce qui va se passer :${NC}"
echo "• Le playbook va définir une variable 'nom_fichier_taches'"
echo "• Puis tenter de l'utiliser dans import_tasks"
echo "• Ansible va ${RED}ÉCHOUER${NC} car la variable n'existe pas au parse time"
echo ""

confirm "Lancer l'exemple d'échec ?"

print_subtitle "Exécution du playbook..."

# On capture l'erreur car on VEUT qu'il échoue
if ansible-playbook exemple_echec_import.yml 2>&1; then
    print_expected_error "ATTENTION : Le playbook aurait dû échouer mais a réussi !"
else
    print_expected_error "Échec ATTENDU et VOULU : import_tasks ne peut pas utiliser de variables dynamiques"
fi

echo ""
echo -e "${BOLD}Explication :${NC}"
echo "• import_tasks est évalué au ${YELLOW}PARSE TIME${NC} (avant l'exécution)"
echo "• À ce moment-là, la variable n'existe pas encore"
echo "• Ansible ne peut pas résoudre {{ nom_fichier_taches }}"
echo ""

confirm "Continuer vers la solution ?"

# ============================================================================
# DÉMONSTRATION 2 : SUCCÈS avec include_tasks
# ============================================================================

print_title "✅ DÉMONSTRATION 2 : SUCCÈS avec include_tasks"

echo -e "${BOLD}Objectif pédagogique :${NC}"
echo "Montrer qu'on PEUT utiliser une variable définie dynamiquement"
echo "dans le nom du fichier avec include_tasks."
echo ""
echo -e "${BOLD}Ce qui va se passer :${NC}"
echo "• Le playbook va définir des variables dynamiquement"
echo "• Utiliser include_tasks avec ces variables"
echo "• ${GREEN}RÉUSSIR${NC} car include_tasks est évalué au run time"
echo "• Bonus : démonstration de boucles (impossible avec import)"
echo ""

confirm "Lancer l'exemple de succès ?"

print_subtitle "Exécution du playbook..."

if ansible-playbook exemple_succes_include.yml; then
    print_success "SUCCÈS : include_tasks fonctionne parfaitement avec les variables dynamiques !"
else
    echo -e "${RED}Erreur inattendue : Ce playbook aurait dû réussir.${NC}"
fi

echo ""
echo -e "${BOLD}Explication :${NC}"
echo "• include_tasks est évalué au ${GREEN}RUN TIME${NC} (pendant l'exécution)"
echo "• À ce moment-là, toutes les variables sont définies"
echo "• Ansible peut résoudre les variables sans problème"
echo "• Bonus : on peut utiliser des boucles (loop) avec include_tasks"
echo ""

confirm "Continuer vers la démonstration des tags ?"

# ============================================================================
# DÉMONSTRATION 3 : TAGS et VISIBILITÉ
# ============================================================================

print_title "🏷️ DÉMONSTRATION 3 : TAGS et VISIBILITÉ"

echo -e "${BOLD}Objectif pédagogique :${NC}"
echo "Montrer que les tags se comportent différemment selon la méthode utilisée."
echo ""

# ─────────────────────────────────────────────────────────────────────────
# 3.1 : Lister les tags
# ─────────────────────────────────────────────────────────────────────────

print_subtitle "3.1 - Lister tous les tags disponibles"

echo "Commande : ansible-playbook exemple_tags_import_vs_include.yml --list-tags"
echo ""
confirm "Lancer ?"

ansible-playbook exemple_tags_import_vs_include.yml --list-tags

echo ""
echo -e "${BOLD}Observations importantes :${NC}"
echo "• Avec ${GREEN}import_tasks${NC} : Vous voyez les tags 'config', 'install', 'deploy'"
echo "• Avec ${YELLOW}include_tasks${NC} : Vous voyez seulement 'include_demo'"
echo ""
echo -e "${BOLD}Pourquoi ?${NC}"
echo "• import_tasks = statique → tags visibles au parsing"
echo "• include_tasks = dynamique → tags visibles seulement à l'exécution"
echo ""

confirm "Continuer ?"

# ─────────────────────────────────────────────────────────────────────────
# 3.2 : Lister les tâches
# ─────────────────────────────────────────────────────────────────────────

print_subtitle "3.2 - Lister toutes les tâches disponibles"

echo "Commande : ansible-playbook exemple_tags_import_vs_include.yml --list-tasks"
echo ""
confirm "Lancer ?"

ansible-playbook exemple_tags_import_vs_include.yml --list-tasks

echo ""
echo -e "${BOLD}Observations importantes :${NC}"
echo "• Avec ${GREEN}import_tasks${NC} : Toutes les tâches importées sont listées"
echo "• Avec ${YELLOW}include_tasks${NC} : Seule la tâche include est listée"
echo ""

confirm "Continuer ?"

# ─────────────────────────────────────────────────────────────────────────
# 3.3 : Exécuter avec un tag spécifique
# ─────────────────────────────────────────────────────────────────────────

print_subtitle "3.3 - Exécuter seulement les tâches avec le tag 'config'"

echo "Commande : ansible-playbook exemple_tags_import_vs_include.yml --tags 'config'"
echo ""
confirm "Lancer ?"

ansible-playbook exemple_tags_import_vs_include.yml --tags "config"

echo ""
echo -e "${BOLD}Observations importantes :${NC}"
echo "• Avec ${GREEN}import_tasks${NC} : La tâche 'Configuration du serveur' s'exécute"
echo "• Avec ${YELLOW}include_tasks${NC} : Aucune tâche ne s'exécute (tag non reconnu)"
echo ""

confirm "Voir l'exécution complète ?"

# ─────────────────────────────────────────────────────────────────────────
# 3.4 : Exécution normale
# ─────────────────────────────────────────────────────────────────────────

print_subtitle "3.4 - Exécution complète (sans filtre de tags)"

ansible-playbook exemple_tags_import_vs_include.yml

# ============================================================================
# RÉSUMÉ FINAL
# ============================================================================

print_title "📊 RÉSUMÉ FINAL"

echo -e "${BOLD}Tableau comparatif :${NC}"
echo ""
echo "┌────────────────────────────┬──────────────────┬───────────────────┐"
echo "│ ${BOLD}CRITÈRE${NC}                    │ ${GREEN}import_tasks${NC}     │ ${YELLOW}include_tasks${NC}     │"
echo "├────────────────────────────┼──────────────────┼───────────────────┤"
echo "│ Moment d'évaluation        │ Parse time       │ Run time          │"
echo "│ Variables dynamiques       │ ❌ Non           │ ✅ Oui            │"
echo "│ Boucles (loop)             │ ❌ Non           │ ✅ Oui            │"
echo "│ Tags visibles --list-tags  │ ✅ Oui           │ ❌ Non            │"
echo "│ Tâches visibles --list-*   │ ✅ Oui           │ ❌ Non            │"
echo "│ Condition when globale     │ ⚠️ Par tâche     │ ✅ Globale        │"
echo "│ Performance                │ ✅ Meilleure     │ ⚠️ Légèrement -   │"
echo "└────────────────────────────┴──────────────────┴───────────────────┘"
echo ""

echo -e "${BOLD}Règle d'or :${NC}"
echo ""
echo -e "🎯 Utilisez ${GREEN}import_tasks${NC} quand :"
echo "   • Le nom du fichier est fixe (pas de variable)"
echo "   • Vous voulez voir les tags avec --list-tags"
echo "   • Vous voulez la meilleure performance"
echo ""
echo -e "🎯 Utilisez ${YELLOW}include_tasks${NC} quand :"
echo "   • Le nom du fichier contient une variable"
echo "   • Vous utilisez une boucle (loop/with_items)"
echo "   • Vous voulez une condition globale avec when"
echo ""

print_title "✨ DÉMONSTRATION TERMINÉE"

echo "Fichiers disponibles pour référence :"
echo "  📖 README_IMPORT_VS_INCLUDE.md - Guide complet"
echo "  📝 demo_import_vs_include.yml - Documentation théorique"
echo "  🔴 exemple_echec_import.yml - Exemple d'échec"
echo "  ✅ exemple_succes_include.yml - Exemple de succès"
echo "  🏷️ exemple_tags_import_vs_include.yml - Comparaison tags"
echo ""
echo "Pour relancer ce script : ./demo_import_include.sh"
echo ""
echo -e "${GREEN}Bon enseignement ! 🎓${NC}"
echo ""

