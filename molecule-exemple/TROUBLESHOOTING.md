# 🔧 Dépannage Molecule - Problèmes courants

## ❌ Erreur : "Conditionals must have a boolean result" ⭐ NOUVEAU

### Symptôme
```
Conditional result (True) was derived from value of type 'str' at "<environment variable 'HOME'>". 
Conditionals must have a boolean result.
```

### Cause
**Incompatibilité entre Ansible 2.17+ et molecule-docker**. 

Ansible 2.17 est plus strict avec les conditionnels, mais `molecule-docker` n'a pas encore été mis à jour pour respecter cette nouvelle règle.

### Solution 1 : Utiliser le script wrapper ✅ RECOMMANDÉ
```bash
cd nginx-simple
./test.sh  # Au lieu de "molecule test"
```

Le script `test.sh` définit automatiquement les bonnes variables d'environnement.

### Solution 2 : Variable d'environnement manuelle
```bash
export ANSIBLE_ALLOW_BROKEN_CONDITIONALS=True
molecule test
```

### Solution 3 : Mettre à jour molecule-docker
```bash
# Essayer la dernière version
pip install --upgrade molecule molecule-docker

# Si ça ne suffit pas, installer depuis GitHub
pip install git+https://github.com/ansible-community/molecule-docker.git
```

---

## ❌ Erreur : "Error while fetching server API version"

### Symptôme
```
docker.errors.DockerException: Error while fetching server API version: 
('Connection aborted.', FileNotFoundError(2, 'No such file or directory'))
```

### Cause
**Docker Desktop n'est pas démarré** sur votre Mac.

### Solution

#### Sur macOS :
```bash
# Ouvrir Docker Desktop
open -a Docker

# Attendre 10-15 secondes que Docker démarre
# Vérifier que Docker est bien lancé :
docker ps
```

Vous devriez voir :
```
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

#### Sur Linux :
```bash
# Démarrer le service Docker
sudo systemctl start docker

# Vérifier
docker ps
```

---

## ❌ Erreur : "permission denied" avec Docker

### Symptôme
```
Got permission denied while trying to connect to the Docker daemon socket
```

### Solution (Linux uniquement)
```bash
# Ajouter votre utilisateur au groupe docker
sudo usermod -aG docker $USER

# Se déconnecter et se reconnecter
# Ou relancer le shell :
newgrp docker

# Vérifier
docker ps
```

---

## ❌ Erreur : Vérifier les versions installées

Si vous avez des problèmes, vérifiez d'abord vos versions :

```bash
# Versions des outils
python --version      # Doit être 3.8+
ansible --version     # Si 2.17+, utilisez le script test.sh
molecule --version    # Doit être 6.0+
docker --version

# Packages Python installés
pip list | grep molecule
pip list | grep ansible
```

### Versions recommandées pour l'enseignement

```bash
# Installation propre
pip install molecule==6.0.3 \
            molecule-docker==2.1.0 \
            ansible-core==2.16.7 \
            docker
```

> **Note** : Avec Ansible 2.16, pas besoin du workaround des conditionnels cassés !

---

## 🐛 Déboguer efficacement

### Workflow de débogage

1. **Garder le conteneur après erreur** :
```bash
export ANSIBLE_ALLOW_BROKEN_CONDITIONALS=True
molecule test --destroy=never
```

2. **Se connecter** :
```bash
molecule login
```

3. **Inspecter** :
```bash
# Services
systemctl status nginx

# Logs
journalctl -xe
tail -f /var/log/nginx/error.log

# Processus et ports
ps aux | grep nginx
netstat -tuln | grep 80
```

4. **Nettoyer** :
```bash
molecule destroy
```

### Mode verbeux
```bash
# Ansible verbeux
ANSIBLE_ALLOW_BROKEN_CONDITIONALS=True molecule converge -- -vvv

# Molecule verbeux
ANSIBLE_ALLOW_BROKEN_CONDITIONALS=True molecule --debug converge
```

---

##  Réinitialisation complète

Si tout est bloqué :

```bash
# 1. Détruire toutes les instances Molecule
cd nginx-simple
molecule destroy

# Si ça échoue :
export ANSIBLE_ALLOW_BROKEN_CONDITIONALS=True
molecule destroy

# 2. Supprimer les conteneurs Docker orphelins
docker rm -f $(docker ps -aq) 2>/dev/null || true

# 3. Nettoyer
docker system prune -f

# 4. Recommencer
./test.sh
```

---

## 📋 Checklist avant de commencer

Avant de lancer Molecule, vérifiez :

- [ ] Docker Desktop est démarré → `docker ps`
- [ ] Python 3.8+ installé → `python --version`
- [ ] Molecule installé → `molecule --version`
- [ ] ansible-docker installé → `pip list | grep molecule-docker`
- [ ] Vous êtes dans le bon dossier → `cd nginx-simple`
- [ ] Utilisez `./test.sh` si Ansible 2.17+

---

## 🆘 Solutions rapides par erreur

| Erreur | Commande rapide |
|--------|----------------|
| Conditionals must have boolean | `./test.sh` |
| Docker API version | `open -a Docker` puis attendre |
| Permission denied Docker | (Linux) `sudo usermod -aG docker $USER` |
| Container failed to start | Vérifier `molecule.yml` (privileged, volumes) |
| Service failed | `molecule login` puis `systemctl status nginx` |
| Idempotence failed | Revoir les tâches (ajouter mode, changed_when) |

---

## 📞 Besoin d'aide supplémentaire ?

1. **Regardez les logs complets** :
```bash
./test.sh 2>&1 | tee molecule-debug.log
```

2. **Créer un environnement propre** :
```bash
python -m venv venv-molecule
source venv-molecule/bin/activate
pip install molecule molecule-docker 'ansible-core<2.17' docker
```

3. **Consultez la documentation** :
- https://molecule.readthedocs.io/
- https://github.com/ansible-community/molecule-docker
- https://docs.ansible.com/

