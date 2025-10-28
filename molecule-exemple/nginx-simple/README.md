# 🚀 Exemple Minimal : Rôle nginx-simple avec Molecule

## 📖 Qu'est-ce que ce rôle fait ?

Ce rôle très simple :
1. Installe nginx
2. Crée une page d'accueil personnalisée
3. Démarre le service nginx

## 🗂️ Structure des fichiers

```
nginx-simple/
├── defaults/
│   └── main.yml              # Variables par défaut (port, contenu)
├── tasks/
│   └── main.yml              # Actions du rôle (installer, configurer)
├── molecule/
│   └── default/
│       ├── molecule.yml      # Config Molecule (quel OS tester, comment)
│       ├── converge.yml      # Comment appliquer le rôle
│       └── verify.yml        # Tests de vérification
└── README.md                 # Ce fichier !
```

## 🎯 Comprendre les fichiers Molecule

### 1. `molecule.yml` - Configuration

Ce fichier définit **comment** tester :
- **platforms** : Sur quel OS ? (ici Ubuntu 22.04 dans Docker)
- **driver** : Avec quoi ? (Docker, Vagrant, Podman...)
- **provisioner** : Avec quel outil ? (Ansible)

### 2. `converge.yml` - Application du rôle

C'est un playbook classique qui dit :
> "Applique le rôle nginx-simple sur la machine de test"

### 3. `verify.yml` - Tests

C'est un playbook avec des vérifications :
- ✅ Nginx est installé ?
- ✅ Le service tourne ?
- ✅ Le port 80 est ouvert ?
- ✅ La page web fonctionne ?

## 🚀 Commandes pour tester

### Test complet (recommandé pour débutants)

```bash
cd nginx-simple

# Option 1 : Utiliser le script wrapper (recommandé si Ansible 2.17+)
./test.sh

# Option 2 : Avec variable d'environnement
export ANSIBLE_ALLOW_BROKEN_CONDITIONALS=True
molecule test

# Option 3 : Directement (peut échouer avec Ansible 2.17+)
molecule test
```

> **Note** : Si vous avez l'erreur "Conditionals must have a boolean result", utilisez `./test.sh` à la place de `molecule test`.

Cela va :
1. Créer un conteneur Ubuntu
2. Appliquer le rôle
3. Vérifier que nginx fonctionne
4. Vérifier l'idempotence
5. Détruire le conteneur

### Étape par étape (pour comprendre)

```bash
# 1. Créer le conteneur de test
molecule create

# 2. Appliquer le rôle
molecule converge

# 3. Lancer les tests
molecule verify

# 4. Se connecter au conteneur pour inspecter
molecule login

# 5. Détruire l'environnement
molecule destroy
```

## 🔍 Déboguer en cas d'erreur

Si `molecule test` échoue :

```bash
# Garder le conteneur après échec pour inspecter
molecule test --destroy=never

# Se connecter au conteneur
molecule login

# Inspecter manuellement
curl localhost
systemctl status nginx
```

## 📝 Exercice pour les élèves

1. **Exercice 1** : Changer le port nginx de 80 à 8080
   - Modifier `defaults/main.yml`
   - Modifier la configuration nginx dans `tasks/main.yml`
   - Adapter le test de port dans `verify.yml`
   - Tester avec `molecule test`

2. **Exercice 2** : Ajouter un test
   - Dans `verify.yml`, ajouter un test qui vérifie que le fichier `/var/www/html/index.html` existe

3. **Exercice 3** : Tester sur plusieurs OS
   - Dans `molecule.yml`, ajouter une deuxième plateforme (Debian 11 par exemple)
   - Lancer `molecule test` pour tester sur les deux

## 💡 Pourquoi c'est utile ?

Sans Molecule :
```bash
# À faire manuellement à chaque fois...
vagrant up
ansible-playbook playbook.yml
ssh dans_la_vm
# tester manuellement
vagrant destroy
```

Avec Molecule :
```bash
molecule test  # Et voilà ! 🎉
```

## 🐳 Prérequis

- Python 3
- Docker (doit être démarré)
- Molecule installé : `pip install molecule molecule-docker`

## 📚 Pour aller plus loin

- Tester sur plusieurs OS simultanément
- Utiliser des linters (ansible-lint, yamllint)
- Intégrer dans une CI/CD (GitLab CI, GitHub Actions)
- Utiliser TestInfra pour des tests plus avancés

