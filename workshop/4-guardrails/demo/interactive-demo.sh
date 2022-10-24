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

    deployGatekeeper

    privilegedEscalation

    readonlyFilesystem

    echo
    message "This concludes using Gatekeeper to defend against insecure workloads being deployed!"
    exit 0
}

function setup() {
    run "echo Setting up environment for interactive demo 'security context'"
    run "echo -n ."
    run "kubectl config set-context \$(kubectl config current-context) --namespace=sec-ctx > /dev/null"
    run "echo -n ."
}

function deployGatekeeper() {
  heading "1. Install Gatekeeper"

  printAndRun "helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts"

  printAndRun "helm install gatekeeper/gatekeeper  \
      --name-template=gatekeeper \
      --namespace gatekeeper-system --create-namespace \
      --set enableExternalData=true \
      --set controllerManager.dnsPolicy=ClusterFirst,audit.dnsPolicy=ClusterFirst"

  message "====================================="

  message "Waiting for Gatekeeper to be ready"
  printAndRun "kubectl wait --for=condition=available --timeout=600s deployment/gatekeeper-controller-manager -n gatekeeper-system"
  pressKeyToContinue
  message "====================================="

}

function privilegedEscalation() {
    heading "2. Block privilege escalation"

    subHeading "2.1 Deploy the ConstraintTemplate"
    printFile "${ABSOLUTE_BASEDIR}"/01-privilege-escalation/constraint-template.yaml
    (cd "${ABSOLUTE_BASEDIR}" && printAndRun "kubectl apply -f 01-privilege-escalation/constraint-template.yaml")
    pressKeyToContinue
    message "====================================="

    subHeading "2.2 Deploy the Constraint"
    printFile "${ABSOLUTE_BASEDIR}"/01-privilege-escalation/constraint.yaml
    (cd "${ABSOLUTE_BASEDIR}" && printAndRun "kubectl apply -f 01-privilege-escalation/constraint.yaml")
    pressKeyToContinue
    message "====================================="

    subHeading "2.3 Attempt to create a pod with privilege escalation"
    printFile "${ABSOLUTE_BASEDIR}"/01-privilege-escalation/example-disallowed.yaml
    (cd "${ABSOLUTE_BASEDIR}" && printAndRun "kubectl apply -f 01-privilege-escalation/example-disallowed.yaml")
    message "We successfully blocked the creation of the pod with privilege escalation enabled 🎉"
    pressKeyToContinue
    message "====================================="

    subHeading "2.4 Attempt to create a pod without privilege escalation 🤞"
    printFile "${ABSOLUTE_BASEDIR}"/01-privilege-escalation/example-allowed.yaml
    (cd "${ABSOLUTE_BASEDIR}" && printAndRun "kubectl apply -f 01-privilege-escalation/example-allowed.yaml")
    pressKeyToContinue
    message "====================================="
}

function readonlyFilesystem() {
    heading "3. Block running workloads with a readonly filesystem"

    subHeading "3.1 Deploy the ConstraintTemplate"
    printFile "${ABSOLUTE_BASEDIR}"/02-read-only-root-filesystem/constraint-template.yaml
    (cd "${ABSOLUTE_BASEDIR}" && printAndRun "kubectl apply -f 02-read-only-root-filesystem/constraint-template.yaml")
    pressKeyToContinue
    message "====================================="

    subHeading "3.2 Deploy the Constraint"
    printFile "${ABSOLUTE_BASEDIR}"/02-read-only-root-filesystem/constraint.yaml
    (cd "${ABSOLUTE_BASEDIR}" && printAndRun "kubectl apply -f 02-read-only-root-filesystem/constraint.yaml")
    pressKeyToContinue
    message "====================================="

    subHeading "3.3 Attempt to create a pod with a writeable filesystem"
    printFile "${ABSOLUTE_BASEDIR}"/02-read-only-root-filesystem/example-disallowed.yaml
    (cd "${ABSOLUTE_BASEDIR}" && printAndRun "kubectl apply -f 02-read-only-root-filesystem/example-disallowed.yaml")
    message "We successfully blocked the creation of the pod with a writeable filesystem 🎉"
    pressKeyToContinue
    message "====================================="

    subHeading "3.4 Attempt to create a pod with a readonly root filesystem 🤞"
    printFile "${ABSOLUTE_BASEDIR}"/02-read-only-root-filesystem/example-allowed.yaml
    (cd "${ABSOLUTE_BASEDIR}" && printAndRun "kubectl apply -f 02-read-only-root-filesystem/example-allowed.yaml")
    pressKeyToContinue
    message "====================================="
}

main "$@"

}