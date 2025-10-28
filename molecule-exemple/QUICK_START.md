# 🚀 Guide de démarrage rapide - Molecule

## Prérequis

```bash
# Vérifier que Docker tourne
docker ps

# Installer Molecule
pip install molecule molecule-docker ansible

# Vérifier l'installation
molecule --version
```

## Tester l'exemple (2 minutes)

```bash
# Aller dans l'exemple
cd molecule-exemple/nginx-simple

# Lancer le test complet
molecule test
```

**C'est tout !** Molecule va automatiquement :
1. ✅ Créer un conteneur Ubuntu
2. ✅ Installer nginx via le rôle
3. ✅ Vérifier que tout fonctionne
4. ✅ Nettoyer

---

## Comprendre étape par étape

Si vous voulez voir ce qui se passe :

```bash
# 1️⃣ Créer l'environnement de test (conteneur)
molecule create
# → Crée un conteneur Ubuntu avec Ansible installé

# 2️⃣ Appliquer le rôle
molecule converge
# → Lance le playbook converge.yml qui applique le rôle nginx-simple

# 3️⃣ Se connecter pour inspecter (optionnel)
molecule login
# → SSH dans le conteneur pour voir nginx en action
#   Essayez : curl localhost
#   Sortir avec : exit

# 4️⃣ Lancer les tests
molecule verify
# → Lance le playbook verify.yml avec tous les tests

# 5️⃣ Nettoyer
molecule destroy
# → Supprime le conteneur
```

---

## En cas d'erreur

### Docker n'est pas disponible
```bash
# Sur macOS
open -a Docker

# Vérifier que ça tourne
docker ps
```

### Permission denied sur Docker
```bash
# Ajouter votre utilisateur au groupe docker (Linux)
sudo usermod -aG docker $USER
# Puis se reconnecter
```

### "command not found: molecule"
```bash
# Installer avec pip
pip install molecule molecule-docker

# Ou avec pip3
pip3 install molecule molecule-docker
```

---

## Prochain niveau : Créer son propre rôle

```bash
# Créer un nouveau rôle avec Molecule pré-configuré
molecule init role mon_super_role --driver-name docker

# Structure créée automatiquement :
# mon_super_role/
# ├── tasks/main.yml
# ├── molecule/
# │   └── default/
# │       ├── molecule.yml
# │       ├── converge.yml
# │       └── verify.yml
# └── ...
```

---

## Commandes essentielles

| Commande | Description |
|----------|-------------|
| `molecule create` | Crée l'environnement de test |
| `molecule converge` | Applique le rôle |
| `molecule verify` | Lance les tests |
| `molecule test` | Cycle complet (create + converge + verify + destroy) |
| `molecule login` | Se connecter au conteneur |
| `molecule destroy` | Détruire l'environnement |
| `molecule list` | Liste les instances Molecule |

---

## Tips pour l'enseignement

1. **Montrer d'abord sans Molecule** : Faites installer nginx manuellement pour qu'ils voient la différence
2. **Lancer molecule test ensemble** : Laissez-les voir la magie opérer
3. **Explorer avec molecule login** : Montrez qu'il y a vraiment nginx qui tourne
4. **Faire casser quelque chose** : Modifiez le rôle pour qu'il échoue, montrez comment Molecule détecte l'erreur
5. **Exercice pratique** : Demandez-leur de modifier le port et d'adapter les tests

---

## Aide-mémoire visuel

```
┌─────────────────────────────────────────────┐
│  molecule test                              │
│  ↓                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │ CREATE   │→ │ CONVERGE │→ │  VERIFY  │ │
│  │ (Docker) │  │  (Role)  │  │  (Tests) │ │
│  └──────────┘  └──────────┘  └──────────┘ │
│  ↓                                          │
│  ┌──────────┐                               │
│  │ DESTROY  │ ← Si tout va bien             │
│  └──────────┘                               │
└─────────────────────────────────────────────┘
```

Bonne découverte de Molecule ! 🎉

