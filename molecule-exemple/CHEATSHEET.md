# 📋 Molecule - Aide-mémoire

## Commandes essentielles

| Commande | Description | Quand l'utiliser ? |
|----------|-------------|-------------------|
| `molecule test` | Cycle complet (create→converge→verify→destroy) | ✅ Test final avant commit |
| `molecule create` | Crée l'environnement de test | Début du développement |
| `molecule converge` | Applique le rôle | Après chaque modification |
| `molecule verify` | Lance les tests | Vérifier que tout marche |
| `molecule destroy` | Détruit l'environnement | Nettoyage |
| `molecule login` | SSH dans le conteneur | 🔍 Déboguer |
| `molecule list` | Liste les instances | Voir ce qui tourne |
| `molecule reset` | Reset complet | En cas de blocage |

---

## Workflow typique de développement

### 🚀 Première fois
```bash
# Créer l'environnement
molecule create

# Appliquer le rôle (et le réappliquer après chaque modif)
molecule converge

# Tester
molecule verify

# Se connecter pour inspecter (optionnel)
molecule login

# Nettoyer
molecule destroy
```

### 🔄 En développement (itérations rapides)
```bash
# Modifier le rôle...
# Puis :
molecule converge  # Applique les changements
molecule verify    # Vérifie que ça marche
```

### ✅ Avant de commit
```bash
molecule test  # Test complet
```

---

## Structure des fichiers

```
mon-role/
├── defaults/
│   └── main.yml              # 📝 Variables par défaut
│
├── tasks/
│   └── main.yml              # 🔨 Tâches du rôle
│
├── templates/                # 📄 Templates Jinja2 (optionnel)
│   └── config.j2
│
├── handlers/                 # 🔔 Handlers (optionnel)
│   └── main.yml
│
├── molecule/
│   └── default/
│       ├── molecule.yml      # ⚙️  Configuration Molecule
│       ├── converge.yml      # 🎯 Comment appliquer le rôle
│       └── verify.yml        # ✅ Tests de vérification
│
└── README.md                 # 📖 Documentation
```

---

## Anatomie de molecule.yml

```yaml
---
# Driver : Comment créer l'environnement
driver:
  name: docker              # ou podman, vagrant...

# Plateformes : Sur quoi tester
platforms:
  - name: instance          # Nom du conteneur
    image: ubuntu:22.04     # Image Docker
    privileged: true        # Pour systemd
    volumes:                # Montages nécessaires
      - /sys/fs/cgroup:/sys/fs/cgroup:rw
    command: /lib/systemd/systemd

# Provisioner : Comment appliquer
provisioner:
  name: ansible

# Verifier : Comment vérifier
verifier:
  name: ansible
```

---

## Anatomie de converge.yml

```yaml
---
# Playbook qui applique le rôle
- name: Converge
  hosts: all
  become: true              # Utiliser sudo
  
  tasks:
    - name: "Inclure le rôle"
      include_role:
        name: mon-role
```

---

## Anatomie de verify.yml

```yaml
---
# Playbook avec les tests
- name: Verify
  hosts: all
  become: true
  
  tasks:
    # Test 1 : Package installé
    - name: Vérifier que nginx est installé
      package:
        name: nginx
        state: present
      check_mode: yes
      register: result
      failed_when: result is changed

    # Test 2 : Service démarré
    - name: Vérifier que nginx tourne
      service:
        name: nginx
        state: started
      check_mode: yes
      register: result
      failed_when: result is changed

    # Test 3 : Port ouvert
    - name: Vérifier le port 80
      wait_for:
        port: 80
        timeout: 5

    # Test 4 : HTTP répond
    - name: Tester la page web
      uri:
        url: http://localhost:80
        return_content: yes
      register: webpage

    # Test 5 : Contenu correct
    - name: Vérifier le contenu
      assert:
        that:
          - "'Hello' in webpage.content"
        fail_msg: "Contenu incorrect"
```

---

## Types de tests courants

### ✅ Vérifier qu'un package est installé
```yaml
- name: Vérifier nginx installé
  package:
    name: nginx
    state: present
  check_mode: yes
  register: result
  failed_when: result is changed
```

### ✅ Vérifier qu'un service tourne
```yaml
- name: Vérifier que nginx tourne
  service:
    name: nginx
    state: started
  check_mode: yes
  register: result
  failed_when: result is changed
```

### ✅ Vérifier qu'un port est ouvert
```yaml
- name: Vérifier le port 80
  wait_for:
    port: 80
    timeout: 5
```

### ✅ Vérifier qu'un fichier existe
```yaml
- name: Vérifier que le fichier existe
  stat:
    path: /etc/nginx/nginx.conf
  register: result
  failed_when: not result.stat.exists
```

### ✅ Vérifier le contenu d'un fichier
```yaml
- name: Lire le fichier
  slurp:
    src: /etc/nginx/nginx.conf
  register: content

- name: Vérifier le contenu
  assert:
    that:
      - "'server_name' in content.content | b64decode"
```

### ✅ Tester une URL HTTP
```yaml
- name: Tester la page web
  uri:
    url: http://localhost:80
    return_content: yes
    status_code: 200
  register: webpage

- name: Vérifier le contenu
  assert:
    that:
      - "'Welcome' in webpage.content"
```

### ✅ Vérifier une commande
```yaml
- name: Vérifier la version nginx
  command: nginx -v
  register: result
  changed_when: false
  failed_when: result.rc != 0
```

---

## Images Docker recommandées

| OS | Image | Utilisation |
|----|-------|-------------|
| Ubuntu 22.04 | `geerlingguy/docker-ubuntu2204-ansible` | ✅ Recommandé |
| Ubuntu 20.04 | `geerlingguy/docker-ubuntu2004-ansible` | Production courante |
| Debian 11 | `geerlingguy/docker-debian11-ansible` | Serveurs Debian |
| Debian 12 | `geerlingguy/docker-debian12-ansible` | Dernière Debian |
| CentOS 8 | `geerlingguy/docker-centos8-ansible` | RedHat-like |
| Rocky Linux 8 | `geerlingguy/docker-rockylinux8-ansible` | Alternative CentOS |

**Note** : Utiliser les images de Jeff Geerling qui incluent systemd

---

## Déboguer avec Molecule

### Problème : Le rôle échoue
```bash
# Garder le conteneur pour inspecter
molecule test --destroy=never

# Se connecter
molecule login

# Inspecter manuellement
systemctl status nginx
journalctl -xe
curl localhost
```

### Problème : Les tests échouent
```bash
# Lancer seulement converge
molecule converge

# Puis verify en mode verbose
molecule verify -vvv
```

### Problème : Docker ne démarre pas le conteneur
```bash
# Vérifier la config
molecule create -vvv

# Lister les conteneurs Docker
docker ps -a

# Logs du conteneur
docker logs <container_id>
```

---

## Variables d'environnement utiles

```bash
# Changer le scénario par défaut
MOLECULE_SCENARIO=alternative molecule test

# Désactiver la destruction auto
MOLECULE_NO_DESTROY=true molecule test

# Mode verbeux
MOLECULE_DEBUG=1 molecule test
```

---

## Intégration CI/CD (GitLab CI)

```yaml
# .gitlab-ci.yml
test-role:
  stage: test
  image: python:3.9
  services:
    - docker:dind
  before_script:
    - pip install molecule molecule-docker ansible
  script:
    - cd mon-role
    - molecule test
```

---

## Erreurs courantes et solutions

| Erreur | Cause | Solution |
|--------|-------|----------|
| `Cannot connect to Docker` | Docker pas démarré | `systemctl start docker` |
| `Image not found` | Typo dans le nom | Vérifier `molecule.yml` |
| `Failed to create container` | Privilèges insuffisants | Ajouter `privileged: true` |
| `Service failed to start` | systemd pas disponible | Utiliser image avec systemd |
| `Connection refused` | Service pas démarré | Vérifier les logs du service |
| `Idempotence test failed` | Rôle pas idempotent | Revoir les tâches du rôle |

---

## Bonnes pratiques

### ✅ À FAIRE
- Tester sur plusieurs OS
- Écrire des tests complets
- Rendre le rôle idempotent
- Utiliser des variables pour la config
- Documenter dans le README

### ❌ À ÉVITER
- Hardcoder des valeurs
- Oublier les tests de port/service
- Négliger l'idempotence
- Utiliser `shell` quand un module existe
- Tester seulement sur un OS

---

## Checklist avant de publier un rôle

- [ ] `molecule test` passe sans erreur
- [ ] Le rôle est idempotent
- [ ] Tests couvrent tous les aspects
- [ ] Fonctionne sur Ubuntu ET Debian minimum
- [ ] Variables sont documentées
- [ ] README complet avec exemples
- [ ] Pas de secrets en clair
- [ ] Handlers pour les redémarrages
- [ ] Code suit les best practices Ansible

---

## Ressources

- **Doc officielle** : https://molecule.readthedocs.io/
- **Images Docker** : https://hub.docker.com/u/geerlingguy
- **Exemples** : https://galaxy.ansible.com/
- **Best practices** : https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html

