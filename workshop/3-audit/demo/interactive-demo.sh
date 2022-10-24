#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

BASEDIR=$(dirname $0)
ABSOLUTE_BASEDIR="$( cd "${BASEDIR}" && pwd )"
PRINT_ONLY=${PRINT_ONLY:-false}

source "${ABSOLUTE_BASEDIR}"/../../interactive-utils.sh

function main() {
  confirm "Preparing demo in kubernetes cluster '$(kubectl config current-context)'." 'Continue? y/n [n]' || exit 0

  setup
  run "clear"

  install_kubeaudit

  run_kubeaudit_privileged

  run_kubeaudit_privelege_escalation

  run_kubeaudit_non_root

  run_kubeaudit_readonly_rootfs

  message "This concludes our cluster audit, now time to add some defence mechanisms!"
  exit 0
}

function setup() {
    run "echo Setting up environment for interactive demo 'security context'"
    run "echo -n ."
    run "kubectl config set-context \$(kubectl config current-context) --namespace=sec-ctx > /dev/null"
    run "echo -n ."
}

function install_kubeaudit() {

  heading "Instructions ..."
  printFile "${ABSOLUTE_BASEDIR}/../notes/notes.md"

  heading "1. Install kubeaudit"
  message "kubeaudit is a tool to audit Kubernetes clusters for various different security concerns."
  printAndRun "wget -c https://github.com/Shopify/kubeaudit/releases/download/v0.20.0/kubeaudit_0.20.0_linux_amd64.tar.gz -O - | tar -xz"
  printAndRun "sudo mv kubeaudit /usr/local/bin/"
  printAndRun "kubeaudit version"
}

function run_kubeaudit_privileged() {
    heading "2. Check for privileged containers in the sec-ctx"
    printAndRun "kubeaudit privileged --namespace sec-ctx"
    pressKeyToContinue
    message
}

function run_kubeaudit_privelege_escalation() {
  heading "3. Check for containers in the sec-ctx that can escalate privileges"
  printAndRun "kubeaudit privesc --namespace sec-ctx"
  pressKeyToContinue
  message
}

function run_kubeaudit_non_root() {
  heading "4. Check for containers in the sec-ctx that are not running as non-root"
  printAndRun "kubeaudit nonroot --namespace sec-ctx"
  pressKeyToContinue
  message
}

function run_kubeaudit_readonly_rootfs() {
  heading "5. Check for containers in the sec-ctx that are not running with a non read-only root filesystem"
  printAndRun "kubeaudit rootfs --namespace sec-ctx"
  pressKeyToContinue
  message
}

main "$@"

}