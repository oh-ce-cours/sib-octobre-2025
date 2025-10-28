# 🧪 Introduction à Ansible Molecule

## Qu'est-ce que Molecule ?

**Molecule** est un framework de test pour les rôles Ansible. Il permet de :
- ✅ Tester automatiquement vos rôles Ansible
- 🐳 Créer des environnements de test isolés (Docker, Vagrant, etc.)
- 🔄 Vérifier que vos playbooks fonctionnent correctement
- 📊 Valider l'état final de votre système après l'application du rôle

## Pourquoi utiliser Molecule ?

Sans Molecule, pour tester un rôle Ansible, vous devez :
1. Créer manuellement une VM ou un conteneur
2. Appliquer votre rôle
3. Vérifier manuellement que tout fonctionne
4. Détruire l'environnement
5. Recommencer à chaque modification...

**Avec Molecule, tout cela est automatisé !** 🚀

---

## Installation

```bash
# Installer Molecule avec le driver Docker
pip install molecule molecule-docker

# Ou avec Podman
pip install molecule molecule-podman

# Vérifier l'installation
molecule --version
```

---

## Cycle de vie Molecule

Molecule fonctionne en plusieurs étapes :

```
1. CREATE     → Crée l'environnement de test (conteneur/VM)
2. PREPARE    → Prépare l'environnement (installations préalables)
3. CONVERGE   → Exécute votre rôle Ansible
4. IDEMPOTENCE → Vérifie que le rôle est idempotent
5. VERIFY     → Vérifie que tout fonctionne (tests)
6. DESTROY    → Détruit l'environnement
```

Commandes principales :
```bash
molecule create      # Crée l'environnement
molecule converge    # Applique le rôle
molecule verify      # Lance les tests
molecule test        # Lance tout le cycle complet
molecule destroy     # Détruit l'environnement
```

---

## Structure d'un rôle avec Molecule

```
mon_role/
├── defaults/
│   └── main.yml           # Variables par défaut
├── tasks/
│   └── main.yml           # Tâches du rôle
├── molecule/
│   └── default/
│       ├── molecule.yml   # Configuration Molecule
│       ├── converge.yml   # Playbook qui applique le rôle
│       └── verify.yml     # Tests à exécuter
└── README.md
```

---

## Voir l'exemple minimal

👉 Consultez le dossier `nginx-simple/` pour un exemple concret et commenté !

---

## Commandes pour tester l'exemple

```bash
cd nginx-simple

# Tester le rôle complet (cycle complet)
molecule test

# Ou pas à pas pour mieux comprendre :
molecule create     # Crée le conteneur
molecule converge   # Applique le rôle
molecule verify     # Vérifie que nginx fonctionne
molecule destroy    # Nettoie
```

---

## Exercice pour les élèves

Après avoir compris l'exemple nginx-simple, demandez aux élèves de :
1. Modifier le port d'écoute de nginx (80 → 8080)
2. Ajouter un test pour vérifier le nouveau port
3. Lancer `molecule test` pour valider

---

## Ressources

- [Documentation officielle Molecule](https://molecule.readthedocs.io/)
- [Ansible Galaxy](https://galaxy.ansible.com/) - Exemples de rôles avec Molecule

