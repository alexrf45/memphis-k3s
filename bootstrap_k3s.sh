#!/bin/bash

# age -d secret-access.enc >secret-access-key
#
# age -d access-key-id.enc >access-key
#
# age -d pihole.enc >.pihole.env
#
# age -d cf.enc >.cf.env
#
# age -d harbor.enc >.harbor.env
#
# age -d secrets.enc >secrets.yaml
#
#ansible-playbook -i inventory/hosts.yaml -K playbooks/auditing-k3s.yaml

ansible-playbook -i inventory/hosts.yaml -e @secrets.yaml --ask-vault-password -K playbooks/k3s.yaml

scp osiris:/etc/rancher/k3s/k3s.yaml $HOME/.kube/config

sed -ie s/127.0.0.1/10.3.3.10/g $HOME/.kube/config

kubectl apply -f ./manifests/namespaces.yaml
#
kubectl create secret generic awssm-secret \
  --from-file=./access-key --from-file=./secret-access-key \
  -n external-secrets
kubectl create secret generic pihole-password \
  --from-env-file=./.pihole.env \
  -n pihole-system
#
kubectl create secret generic cloudflare-token-secret \
  --from-env-file=./.cf.env \
  -n kube-system
#
kubectl create secret generic operator-oauth \
  --from-env-file=./.tailscale.env \
  -n tailscale-operator
#
kubectl create secret generic harbor-admin-password \
  --from-env-file=./.harbor.env \
  -n harbor
#
kubectl create secret generic harbor-crypto \
  --from-env-file=./.harbor.env \
  -n harbor
#
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.78.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.78.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.78.1/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.78.1/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.78.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.78.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.78.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.78.1/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.78.1/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.78.1/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml

kubectl label node horus bastet anubis node-role.kubernetes.io/worker=true
#
#k create secret generic basic-auth --from-file=auth -n monitoring
#kubectl create secret generic basic-auth --from-file=auth -n storage
#kubectl create secret generic harbor-admin-password --from-env-file=./.harbor.env -n harbor
#kubectl create secret generic harbor-crypto --from-env-file=./.harbor.env -n harbor
