# Guide : Résoudre le problème de duplication des machines dans AWX

## 🎯 Problème rencontré

Vous avez plusieurs inventaires dynamiques dans AWX et le dashboard affiche **5000 machines** alors qu'en réalité vous n'en avez que **500**.

### Pourquoi ce problème ?

AWX **additionne tous les hôtes de tous les inventaires**, même s'ils sont identiques. Si une machine apparaît dans 10 inventaires différents, elle est comptée 10 fois !

**Exemple :**
```
📁 Inventaire_VMware       → 500 machines
📁 Inventaire_AWS          → 500 machines (400 en commun avec VMware)
📁 Inventaire_Azure        → 500 machines (300 en commun)
📁 Inventaire_OnPremise    → 500 machines (200 en commun)
---
Dashboard AWX : 2000 machines ❌
Réalité : 600 machines uniques ✅
```

---

## ✅ Solution : Un Inventaire avec Plusieurs Sources

Au lieu d'avoir **plusieurs inventaires distincts**, il faut créer **UN SEUL inventaire avec plusieurs sources dynamiques**.

AWX déduplique automatiquement les machines dans un même inventaire !

---

## 📋 Procédure Étape par Étape

### Étape 1 : Créer l'inventaire consolidé

1. Dans AWX, aller dans **Resources** → **Inventories**
2. Cliquer sur **Add** → **Add inventory**
3. Remplir les informations :
   - **Name** : `Production_Consolidé` (ou un nom de votre choix)
   - **Description** : "Inventaire unique avec toutes les sources dynamiques"
   - **Organization** : Sélectionner votre organisation
4. Cliquer sur **Save**

---

### Étape 2 : Ajouter les sources dynamiques

Pour **chaque inventaire dynamique existant**, vous allez recréer sa source dans le nouvel inventaire :

#### 2.1 Identifier les sources existantes

1. Aller dans un inventaire dynamique existant
2. Cliquer sur l'onglet **Sources**
3. Noter les informations de la source :
   - Type (VMware, AWS, Azure, etc.)
   - Credential utilisé
   - Options de synchronisation
   - Variables supplémentaires

#### 2.2 Recréer la source dans l'inventaire consolidé

1. Aller dans **Production_Consolidé**
2. Cliquer sur l'onglet **Sources**
3. Cliquer sur **Add**
4. Remplir les informations :
   - **Name** : Donner un nom descriptif (ex: "Source_VMware_Prod")
   - **Source** : Sélectionner le type (VMware vCenter, Amazon EC2, etc.)
   - **Credential** : Sélectionner le credential approprié
   - **Update options** : 
     - ☑ Overwrite (pour écraser les données à chaque sync)
     - ☑ Update on launch (optionnel, pour sync automatique)
   - Configurer les options spécifiques au type de source
5. Cliquer sur **Save**

#### 2.3 Répéter pour toutes vos sources

Répétez l'étape 2.2 pour chaque inventaire dynamique que vous aviez.

**Exemple de configuration finale :**
```
📁 Production_Consolidé
   🔌 Source_VMware_Prod
   🔌 Source_AWS_Prod
   🔌 Source_Azure_Prod
   🔌 Source_OpenStack
   🔌 Source_Custom_Script
```

---

### Étape 3 : Synchroniser toutes les sources

#### Option A : Synchronisation manuelle

1. Dans **Production_Consolidé** → onglet **Sources**
2. Pour chaque source, cliquer sur l'icône de synchronisation 🔄
3. Attendre que toutes les synchronisations soient terminées

#### Option B : Synchronisation automatique avec un Workflow

1. Aller dans **Resources** → **Workflow Templates**
2. Cliquer sur **Add**
3. Remplir :
   - **Name** : `Sync_All_Sources`
   - **Organization** : Votre organisation
   - **Inventory** : `Production_Consolidé`
4. Cliquer sur **Save**
5. Cliquer sur **Visualizer** pour éditer le workflow
6. Ajouter un node pour chaque source :
   - Type : **Inventory Source Sync**
   - Sélectionner la source correspondante
7. Les placer en **parallèle** (pas de liens entre eux)
8. Sauvegarder le workflow

**Planifier l'exécution automatique :**
1. Dans le workflow, onglet **Schedules**
2. Cliquer sur **Add**
3. Configurer la fréquence (ex: toutes les heures, tous les jours, etc.)

---

### Étape 4 : Vérifier le résultat

1. Aller dans **Production_Consolidé** → onglet **Hosts**
2. Vérifier le nombre de machines affichées
3. Vous devriez maintenant voir **~500 machines uniques** au lieu de 5000 ! ✅

---

## 🔍 Comment AWX Déduplique ?

AWX considère deux hôtes comme identiques si :

1. **Le nom est identique** (`inventory_hostname`)
2. **OU** la variable `ansible_host` (IP) est identique

**Exemple de déduplication :**
```yaml
# Source VMware trouve :
vm-web-01  ansible_host=192.168.1.10

# Source AWS trouve :
i-12345abc  ansible_host=192.168.1.10

# Résultat dans l'inventaire consolidé :
# AWX garde UNE SEULE machine (déduplication par IP)
# Le nom utilisé sera celui de la première source synchronisée
```

---

## 🧪 Playbook de Vérification

Pour vérifier que la déduplication fonctionne correctement, créez un playbook de test :

```yaml
---
- name: Vérifier le nombre réel de machines
  hosts: all
  gather_facts: no
  tasks:
    - name: Compter les machines uniques
      debug:
        msg: |
          ==========================================
          RAPPORT DE VÉRIFICATION
          ==========================================
          Nombre de machines dans l'inventaire: {{ groups['all'] | length }}
          ==========================================
      run_once: true
      delegate_to: localhost

    - name: Lister les 10 premières machines
      debug:
        msg: "{{ groups['all'][:10] }}"
      run_once: true
      delegate_to: localhost
```

**Utilisation :**
1. Créer un **Job Template** pointant vers ce playbook
2. Sélectionner l'inventaire **Production_Consolidé**
3. Lancer le job
4. Vérifier la sortie dans l'onglet **Output**

---

## 🚀 Playbook Avancé : Détecter les Doublons

Si vous voulez voir en détail les doublons potentiels (avant la déduplication) :

```yaml
---
- name: Analyser les doublons dans l'inventaire
  hosts: all
  gather_facts: yes
  tasks:
    - name: Collecter les informations de chaque hôte
      set_fact:
        host_info:
          nom: "{{ inventory_hostname }}"
          ip: "{{ ansible_host | default(ansible_default_ipv4.address | default('N/A')) }}"
          groupes: "{{ group_names }}"
      
    - name: Agréger toutes les infos
      set_fact:
        all_hosts_info: "{{ ansible_play_hosts | map('extract', hostvars, 'host_info') | list }}"
      run_once: true
      delegate_to: localhost

    - name: Dédupliquer par IP
      set_fact:
        unique_ips: "{{ all_hosts_info | map(attribute='ip') | list | unique }}"
      run_once: true
      delegate_to: localhost

    - name: Afficher le rapport
      debug:
        msg: |
          ==========================================
          RAPPORT D'ANALYSE
          ==========================================
          Total d'hôtes dans l'inventaire: {{ ansible_play_hosts | length }}
          Machines uniques par IP: {{ unique_ips | length }}
          ==========================================
      run_once: true
      delegate_to: localhost

    - name: Créer un dictionnaire des IPs
      set_fact:
        host_by_ip: "{{ host_by_ip | default({}) | combine({item.ip: (host_by_ip[item.ip] | default([])) + [item.nom]}) }}"
      loop: "{{ all_hosts_info }}"
      run_once: true
      delegate_to: localhost

    - name: Afficher les machines avec la même IP (potentiels doublons)
      debug:
        msg: "⚠️  IP {{ item.key }} utilisée par {{ item.value | length }} machines: {{ item.value | join(', ') }}"
      loop: "{{ host_by_ip | dict2items }}"
      when: item.value | length > 1
      run_once: true
      delegate_to: localhost
```

---

## 📊 Avant / Après

### AVANT (Configuration incorrecte)
```
Dashboard AWX:
├── Inventaire_VMware         500 machines
├── Inventaire_AWS            500 machines
├── Inventaire_Azure          500 machines
└── Inventaire_OnPremise      500 machines
---
Total affiché : 2000 machines ❌
```

### APRÈS (Configuration correcte)
```
Dashboard AWX:
└── Production_Consolidé      550 machines ✅
    ├── 🔌 Source_VMware
    ├── 🔌 Source_AWS
    ├── 🔌 Source_Azure
    └── 🔌 Source_OnPremise
---
Total affiché : 550 machines (réel) ✅
```

---

## ⚠️ Points d'Attention

### 1. Ordre de synchronisation

Si deux sources ont des machines avec le **même nom mais des IPs différentes**, AWX gardera les données de la **première source synchronisée**.

**Solution :** Utiliser des noms uniques ou prioriser la source la plus fiable.

### 2. Nettoyage des anciennes données

Après migration vers l'inventaire consolidé, pensez à :
- Désactiver les anciens inventaires (ne pas les supprimer immédiatement)
- Mettre à jour tous les **Job Templates** pour utiliser le nouvel inventaire
- Tester tous vos playbooks avec le nouvel inventaire

### 3. Performance

La synchronisation de plusieurs sources peut prendre du temps. Utilisez :
- **Update on launch** avec précaution (peut ralentir les jobs)
- Un **Workflow de synchronisation** planifié plutôt que des syncs manuelles
- Des **filtres** dans les sources pour limiter les données récupérées

---

## 🎓 Exercice Pratique

1. **Noter** le nombre actuel de machines dans votre dashboard AWX
2. **Créer** l'inventaire consolidé en suivant cette procédure
3. **Migrer** vos 2-3 premières sources dynamiques
4. **Synchroniser** et comparer les résultats
5. **Exécuter** le playbook de vérification
6. **Migrer** le reste des sources une fois validé

---

## 📝 Checklist de Migration

- [ ] Inventaire consolidé créé
- [ ] Sources identifiées et documentées
- [ ] Première source migrée et testée
- [ ] Toutes les sources migrées
- [ ] Workflow de synchronisation créé
- [ ] Planification automatique configurée
- [ ] Job Templates mis à jour
- [ ] Playbooks testés avec le nouvel inventaire
- [ ] Anciens inventaires désactivés
- [ ] Documentation mise à jour

---

## ❓ FAQ

**Q : Est-ce que je perds des données en faisant cette migration ?**  
R : Non, vous ne perdez rien. Vous pouvez garder les anciens inventaires en parallèle pendant la phase de test.

**Q : Que se passe-t-il si deux sources ont la même machine avec des variables différentes ?**  
R : AWX fusionne les variables. En cas de conflit, la dernière source synchronisée écrase les valeurs (si "Overwrite" est activé).

**Q : Puis-je avoir plusieurs inventaires consolidés ?**  
R : Oui ! Vous pouvez créer par exemple :
- `Production_Consolidé` (toutes les sources de prod)
- `Dev_Consolidé` (toutes les sources de dev)
- `Test_Consolidé` (toutes les sources de test)

**Q : Les inventaires Smart étaient censés faire ça, non ?**  
R : Oui, mais ils sont décommissionnés dans les versions récentes d'AWX. Cette méthode est le remplacement officiel.

**Q : Comment savoir quelle source a fourni une machine spécifique ?**  
R : AWX ne garde pas cette information directement. Vous pouvez ajouter des variables personnalisées dans chaque source pour tracer l'origine.

---

## 🔗 Ressources Complémentaires

- [Documentation Ansible - Patterns and Dynamic Inventories](https://docs.ansible.com/ansible/latest/user_guide/intro_patterns.html)

---

**Document créé le 28 octobre 2025**  
**Version 1.0**

