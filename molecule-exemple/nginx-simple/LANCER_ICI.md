# 🚀 LANCER LE TEST MOLECULE

## Commande à exécuter :

```bash
./test.sh
```

## Si ça ne marche pas, essayez :

```bash
export ANSIBLE_ALLOW_BROKEN_CONDITIONALS=True
molecule destroy
molecule test
```

## Étapes du test :

1. ✅ **DESTROY** - Nettoie l'ancien conteneur
2. ✅ **CREATE** - Crée un nouveau conteneur Ubuntu
3. ✅ **CONVERGE** - Installe nginx via le rôle
4. ✅ **IDEMPOTENCE** - Vérifie l'idempotence
5. ✅ **VERIFY** - Lance les tests
6. ✅ **DESTROY** - Nettoie

---

Si tout fonctionne, vous verrez en fin :
```
INFO     default scenario test matrix: ...
INFO     Scenario: default
INFO     Molecule executed 1 scenario (1 passed)
```

🎉 **Succès !**

