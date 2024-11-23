#!/bin/bash

ansible-playbook -i inventory/hosts.yaml -e @secrets.yaml --ask-vault-password playbooks/db.yaml
