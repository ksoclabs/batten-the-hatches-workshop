#!/usr/bin/env bash

source "interactive-utils.sh"

function set_context {
  kubectl create namespace sec-ctx
  kubectl config set-context $(kubectl config current-context) --namespace=sec-ctx
}

function install_ketall {
  wget -c https://github.com/corneliusweig/ketall/releases/download/v1.3.8/get-all-amd64-linux.tar.gz -O - | tar -xz
  sudo mv get-all-amd64-linux /usr/local/bin/ketall
}

function install_kubeaudit {
  wget -c https://github.com/Shopify/kubeaudit/releases/download/v0.20.0/kubeaudit_0.20.0_linux_amd64.tar.gz -O - | tar -xz
  sudo mv kubeaudit /usr/local/bin/kubeaudit
}

function install_workloads {
  kubectl apply -f 1-workloads/demo/
}

function main {
  set_context
  install_ketall
  install_kubeaudit
  install_workloads
}

main "$@"