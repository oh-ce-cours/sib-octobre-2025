# 💪 Exercices pratiques - Molecule

Ces exercices sont conçus pour progresser étape par étape dans la maîtrise de Molecule.

---

## 🟢 Exercice 1 : Découverte (15 min)

**Objectif** : Comprendre le cycle de vie de Molecule

### Étapes :
1. Aller dans le dossier `nginx-simple/`
2. Lancer `molecule test` et observer la sortie
3. Répondre aux questions :
   - Combien de temps prend la création du conteneur ?
   - Combien de tests sont exécutés dans la phase VERIFY ?
   - Le rôle est-il idempotent ? Comment le savez-vous ?

### Solution :
```bash
cd nginx-simple
molecule test
```

---

## 🟢 Exercice 2 : Exploration (20 min)

**Objectif** : Explorer l'environnement de test

### Étapes :
1. Créer l'environnement : `molecule create`
2. Appliquer le rôle : `molecule converge`
3. Se connecter au conteneur : `molecule login`
4. Dans le conteneur, vérifier :
   - Que nginx est installé : `which nginx`
   - Que le service tourne : `systemctl status nginx`
   - Le contenu de la page : `curl localhost`
   - Le fichier créé : `cat /var/www/html/index.html`
5. Sortir : `exit`
6. Nettoyer : `molecule destroy`

### Questions :
- Quelle est la différence entre `converge` et `create` ?
- Pourquoi peut-on utiliser `systemctl` dans le conteneur ?

---

## 🟡 Exercice 3 : Modification simple (30 min)

**Objectif** : Modifier le rôle et adapter les tests

### Tâche :
Changer le message de la page d'accueil nginx.

### Étapes :
1. Ouvrir `nginx-simple/defaults/main.yml`
2. Changer `nginx_index_content` en : `"Bienvenue sur mon serveur ! 🚀"`
3. Ouvrir `nginx-simple/molecule/default/verify.yml`
4. Adapter le test qui vérifie le contenu de la page
5. Tester : `molecule test`

### Solution :

**defaults/main.yml** :
```yaml
nginx_index_content: "Bienvenue sur mon serveur ! 🚀"
```

**verify.yml** (modifier le test existant) :
```yaml
- name: Vérifier le contenu de la page
  assert:
    that:
      - "'Bienvenue sur mon serveur' in webpage.content"
```

---

## 🟡 Exercice 4 : Ajouter un test (30 min)

**Objectif** : Créer un nouveau test de vérification

### Tâche :
Ajouter un test qui vérifie que le fichier `/var/www/html/index.html` existe.

### Indice :
Utiliser le module `stat` d'Ansible.

### Solution :

Ajouter dans `verify.yml` :
```yaml
- name: Vérifier que le fichier index.html existe
  stat:
    path: /var/www/html/index.html
  register: index_file

- name: Valider l'existence du fichier
  assert:
    that:
      - index_file.stat.exists
      - index_file.stat.isreg
    fail_msg: "Le fichier index.html n'existe pas"
    success_msg: "✅ Le fichier index.html existe bien"
```

---

## 🟡 Exercice 5 : Changer le port (45 min)

**Objectif** : Modifier le port d'écoute de nginx

### Tâche :
Faire écouter nginx sur le port 8080 au lieu du port 80.

### Étapes :
1. Ajouter une tâche dans `tasks/main.yml` pour configurer nginx
2. Créer un template de configuration nginx
3. Adapter la variable dans `defaults/main.yml`
4. Modifier TOUS les tests dans `verify.yml` qui font référence au port 80
5. Tester avec `molecule test`

### Solution :

**defaults/main.yml** :
```yaml
nginx_port: 8080
nginx_index_content: "Hello from Ansible Molecule! 🚀"
```

**tasks/main.yml** (ajouter après l'installation) :
```yaml
- name: Configurer nginx sur le port personnalisé
  template:
    src: default.conf.j2
    dest: /etc/nginx/sites-available/default
  notify: restart nginx

- name: S'assurer que nginx est démarré et activé
  service:
    name: nginx
    state: started
    enabled: yes
```

**Créer templates/default.conf.j2** :
```nginx
server {
    listen {{ nginx_port }};
    listen [::]:{{ nginx_port }};
    
    root /var/www/html;
    index index.html;
    
    server_name _;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
```

**verify.yml** (modifier le test du port) :
```yaml
- name: Vérifier que nginx écoute sur le port configuré
  wait_for:
    port: 8080
    timeout: 5

- name: Récupérer la page d'accueil
  uri:
    url: http://localhost:8080
    return_content: yes
  register: webpage
```

---

## 🔴 Exercice 6 : Multi-plateforme (60 min)

**Objectif** : Tester le rôle sur plusieurs distributions

### Tâche :
Faire fonctionner le rôle sur Ubuntu ET Debian.

### Étapes :
1. Modifier `molecule.yml` pour ajouter une deuxième plateforme
2. Adapter `tasks/main.yml` si nécessaire
3. Lancer `molecule test`

### Solution :

**molecule.yml** :
```yaml
platforms:
  - name: ubuntu
    image: geerlingguy/docker-ubuntu2204-ansible:latest
    pre_build_image: true
    privileged: true
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:rw
    cgroupns_mode: host
    command: /lib/systemd/systemd

  - name: debian
    image: geerlingguy/docker-debian11-ansible:latest
    pre_build_image: true
    privileged: true
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:rw
    cgroupns_mode: host
    command: /lib/systemd/systemd
```

Molecule va maintenant tester sur les deux plateformes !

---

## 🔴 Exercice 7 : Test d'échec (45 min)

**Objectif** : Comprendre comment Molecule détecte les erreurs

### Tâche :
Créer volontairement une erreur et voir comment Molecule la détecte.

### Étapes :
1. Dans `tasks/main.yml`, commenter la tâche qui installe nginx
2. Lancer `molecule test`
3. Observer l'erreur
4. Réparer et retester

### Questions de réflexion :
- À quelle étape Molecule détecte-t-il l'erreur ?
- Quel test échoue en premier ?
- Comment le message d'erreur vous aide-t-il à déboguer ?

---

## 🔴 Exercice 8 : Créer son propre rôle (90 min)

**Objectif** : Créer un rôle complet de A à Z avec Molecule

### Tâche :
Créer un rôle `apache-simple` qui :
- Installe Apache
- Crée une page d'accueil personnalisée
- Configure le ServerName

### Étapes :
1. Créer la structure du rôle
2. Créer les fichiers Molecule
3. Écrire les tâches
4. Écrire les tests
5. Tester avec `molecule test`

### Structure attendue :
```
apache-simple/
├── defaults/
│   └── main.yml           # port: 80, server_name, etc.
├── tasks/
│   └── main.yml           # Installation + config
├── templates/
│   └── index.html.j2      # Page d'accueil
│   └── apache.conf.j2     # Config Apache (optionnel)
├── molecule/
│   └── default/
│       ├── molecule.yml
│       ├── converge.yml
│       └── verify.yml
└── README.md
```

### Tests à inclure :
- Apache est installé
- Le service tourne
- Le port 80 est ouvert
- La page d'accueil contient un texte spécifique
- Le fichier de configuration existe

---

## 🎓 Projet final : Rôle complet (2-3 heures)

**Objectif** : Créer un rôle production-ready

### Tâche :
Créer un rôle `wordpress-stack` qui installe :
- Nginx
- PHP-FPM
- MariaDB
- WordPress

### Exigences :
- ✅ Configurable via variables (ports, mots de passe, etc.)
- ✅ Tests complets avec Molecule
- ✅ Idempotent
- ✅ Fonctionne sur Ubuntu ET Debian
- ✅ Documentation README complète

### Tests minimum :
- Tous les services sont démarrés
- Les ports sont ouverts
- WordPress répond sur HTTP
- La base de données est créée
- Les fichiers de config sont présents

---

## 💡 Conseils pour les exercices

1. **Lisez les erreurs** : Molecule donne des messages très explicites
2. **Utilisez `molecule login`** : Connectez-vous pour déboguer
3. **Testez étape par étape** : `create` → `converge` → `verify`
4. **Consultez la doc** : https://molecule.readthedocs.io/
5. **Regardez des exemples** : Ansible Galaxy contient beaucoup de rôles avec Molecule

---

## 🏆 Critères de réussite

Pour chaque exercice, vérifiez que :
- [ ] `molecule test` passe sans erreur
- [ ] Le rôle est idempotent (aucun changement au 2e run)
- [ ] Tous les tests sont pertinents
- [ ] Le code est lisible et commenté
- [ ] Le README explique comment utiliser le rôle

---

## 📚 Pour aller plus loin

Après ces exercices, explorez :
- **Molecule + CI/CD** : Intégrer dans GitLab CI
- **TestInfra** : Framework de test plus avancé
- **Ansible Lint** : Vérifier la qualité du code Ansible
- **Plusieurs scénarios** : `molecule/default/` + `molecule/alternative/`

