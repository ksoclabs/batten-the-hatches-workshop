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

    unnecessaryListPermission

    echo
    message "This concludes securing your rbac permissions!"

}

function setup() {
    run "echo Setting up environment for interactive demo 'security context'"
    run "echo -n ."
    run "kubectl config set-context \$(kubectl config current-context) --namespace=sec-ctx > /dev/null"
    run "echo -n ."
}

function unnecessaryListPermission() {
    heading "1. Giving workloads too many permissions"
    subHeading "1.1 Unnecessary use of LIST permission 😲"

    printFile "${ABSOLUTE_BASEDIR}"/01-list-service-account.yaml
    (cd "${ABSOLUTE_BASEDIR}" && printAndRun "kubectl apply -f 01-list-service-account.yaml")
    pressKeyToContinue
    message "====================================="

    printFile "${ABSOLUTE_BASEDIR}"/01-list-role.yaml
    (cd "${ABSOLUTE_BASEDIR}" && printAndRun "kubectl apply -f 01-list-role.yaml")
    pressKeyToContinue
    message "====================================="

    printFile "${ABSOLUTE_BASEDIR}"/01-list-rolebinding.yaml
    (cd "${ABSOLUTE_BASEDIR}" && printAndRun "kubectl apply -f 01-list-rolebinding.yaml")
    pressKeyToContinue
    message "====================================="

    printFile "${ABSOLUTE_BASEDIR}"/01-list-secret-secret.yaml
    (cd "${ABSOLUTE_BASEDIR}" && printAndRun "kubectl apply -f 01-list-secret-secret.yaml")
    pressKeyToContinue
    message "====================================="

    printFile "${ABSOLUTE_BASEDIR}"/01-list-service-account.yaml
    (cd "${ABSOLUTE_BASEDIR}" && printAndRun "kubectl apply -f 01-list-service-account.yaml")
    pressKeyToContinue
    message "====================================="

    printFile "${ABSOLUTE_BASEDIR}"/01-list-secrets.yaml
    (cd "${ABSOLUTE_BASEDIR}" && printAndRun "kubectl apply -f 01-list-secrets.yaml")
    pressKeyToContinue
    message "====================================="

    message "Note: Stop exec by typing exit."
    printAndRun "kubectl exec -it \$(kubectl get pods  | awk '/^list-secrets/ {print \$1;exit}') -- bash"

    message "============================================"
    printFile "${ABSOLUTE_BASEDIR}"/../notes/01-list-permission.md
    message "Watch also has the same problem as LIST 😲"
    message "============================================"
}

function usingClusterAdmin() {

  heading "2. Giving the default service account cluster admin access 😲"

  printFile "${ABSOLUTE_BASEDIR}"/02-cluster-admin-rolebinding.yaml
  (cd "${ABSOLUTE_BASEDIR}" && printAndRun "kubectl apply -f 02-cluster-admin-rolebinding.yaml")
  pressKeyToContinue
  message "====================================="




}

main "$@"

}