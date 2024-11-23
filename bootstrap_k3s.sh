#!/bin/bash

age -d secret-access.enc >secret-access-key

age -d access-key-id.enc >access-key

age -d pihole.enc >.pihole.env

age -d cf.env >.cf.env

age -d secrets.enc >secrets.yaml

ansible-playbook -i inventory/hosts.yaml -K playbooks/auditing-k3s.yaml

ansible-playbook -i inventory/hosts.yaml -e @secrets.yaml --ask-vault-password -K playbooks/k3s.yaml

scp sean@10.3.3.4:/etc/rancher/k3s/k3s.yaml $HOME/.kube/config

sed -ie s/127.0.0.1/10.3.3.4/g $HOME/.kube/config

kubectl apply -f ./manifests/namespaces.yaml

#kubectl apply -f ./manifests/nginx.yaml

kubectl create \
  -n external-secrets secret generic awssm-secret \
  --from-file=./access-key --from-file=./secret-access-key

kubectl create secret generic pihole-password \
  --from-env-file=./.pihole.env \
  -n pihole-system

kubectl create secret generic cloudflare-token-secret \
  --from-env-file=./.cf.env \
  -n kube-system
