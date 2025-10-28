#!/bin/bash
# Script pour lancer molecule test avec les bonnes variables d'environnement

# Autoriser les conditionnels cassés (bug molecule-docker + Ansible 2.17+)
export ANSIBLE_ALLOW_BROKEN_CONDITIONALS=True
export ANSIBLE_DEPRECATION_WARNINGS=False
export ANSIBLE_HOST_KEY_CHECKING=False

# Lancer molecule test
molecule test "$@"

