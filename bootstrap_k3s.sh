#!/bin/bash

decrypt_age secrets-folder.tar.gz.enc secrets-folder.tar.gz

tar -xzvf secrets-folder.tar.gz

ansible-playbook -i inventory/hosts.yaml -K playbooks/auditing-k3s.yaml

ansible-playbook -i inventory/hosts.yaml -e @secrets.yaml --ask-vault-password -K playbooks/k3s.yaml

scp osiris:/etc/rancher/k3s/k3s.yaml $HOME/.kube/config

sed -ie s/127.0.0.1/10.3.3.10/g $HOME/.kube/config

kubectl apply -f ./manifests/namespaces.yaml

bash ./secrets-folder/k-secrets.sh

kubectl create secret generic pihole-password \
  --from-env-file=./secrets-folder/.pihole.env \
  -n pihole-system

kubectl create \
  -n external-secrets secret generic awssm-secret \
  --from-file=./secrets-folder/access-key --from-file=./secrets-folder/secret-access-key

kubectl create secret generic harbor-admin-password \
  --from-env-file=./secrets-folder/.harbor.env \
  -n harbor

kubectl create secret generic harbor-crypto \
  --from-env-file=./secrets-folder/.harbor.env \
  -n harbor

bash ./manifests/prometheus.sh

kubectl label node horus bastet anubis osiris node-role.kubernetes.io/worker=true
