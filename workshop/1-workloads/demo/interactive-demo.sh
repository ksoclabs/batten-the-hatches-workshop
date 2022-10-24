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

    runAsRoot

    runAsUser

    allowPrivilegeEscalation

    enableServiceLinks

    activateSeccompProfile

    dropCapabilities

    readOnlyRootFilesystem

    allAtOnce

    echo
    message "This concludes securing your workloads!"
    exit 0
}

function setup() {
    run "echo Setting up environment for interactive demo 'security context'"
    run "echo -n ."
    run "kubectl config set-context \$(kubectl config current-context) --namespace=sec-ctx > /dev/null"
    run "echo -n ."
}

function runAsRoot() {
    heading "1. Run as root"

    subHeading "1.1 Pod runs as root"
    printAndRun "kubectl create deployment nginx --image nginx:1.19.3"
    pressKeyToContinue
    message "====================================="

    run "sleep 5"
    printAndRun "kubectl exec \$(kubectl get pods  | awk '/nginx/ {print \$1;exit}') -- id"
    pressKeyToContinue
    message "====================================="

    subHeading "1.2 Same with \"runAsNonRoot: true\""
    printFile "${ABSOLUTE_BASEDIR}"/01-deployment-run-as-non-root.yaml
    pressKeyToContinue
    message "====================================="

    (cd "${ABSOLUTE_BASEDIR}" && printAndRun "kubectl apply -f 01-deployment-run-as-non-root.yaml")
    pressKeyToContinue
    message "====================================="

    printAndRun "kubectl get pod \$(kubectl get pods  | awk '/^run-as-non-root/ {print \$1;exit}')"
    pressKeyToContinue
    message "====================================="

    printAndRun "kubectl describe pod \$(kubectl get pods  | awk '/^run-as-non-root/ {print \$1;exit}') | grep Error"
    pressKeyToContinue
    message "====================================="

    subHeading "1.3 Image that runs as nginx as non-root ➡️  runs as uid != 0"
    printFile "${ABSOLUTE_BASEDIR}"/02-deployment-run-as-non-root-unprivileged.yaml
    pressKeyToContinue
    message "====================================="

    printAndRun "kubectl get pod \$(kubectl get pods  | awk '/^run-as-non-root-unprivileged/ {print \$1;exit}')"
    pressKeyToContinue
    message "====================================="

    printAndRun "kubectl exec \$(kubectl get pods  | awk '/run-as-non-root-unprivileged/ {print \$1;exit}') -- id"
    pressKeyToContinue
    message "====================================="
}

function runAsUser() {
    heading "2. Run as user/group"
    subHeading "2.1 Run nginx as uid/gid 100000"
    printFile "${ABSOLUTE_BASEDIR}"/03-deployment-run-as-user-unprivileged.yaml
    message "====================================="

    printAndRun "kubectl get pod \$(kubectl get pods  | awk '/run-as-user-unprivileged/ {print \$1;exit}')"
    pressKeyToContinue
    message "====================================="

    printAndRun "kubectl exec \$(kubectl get pods  | awk '/run-as-user-unprivileged/ {print \$1;exit}') -- id"
    pressKeyToContinue
    message "====================================="

    subHeading "2.2 Image must be designed to work with \"runAsUser\" and \"runAsGroup\""
    printFile "${ABSOLUTE_BASEDIR}"/04-deployment-run-as-user.yaml
    (cd "${ABSOLUTE_BASEDIR}" && printAndRun "kubectl apply -f 04-deployment-run-as-user.yaml")
    run "sleep 3"
    message "====================================="

    printAndRun "kubectl get pod \$(kubectl get pods  | awk '/^run-as-user/ {print \$1;exit}')"
    pressKeyToContinue
    message "====================================="

    printAndRun "kubectl logs \$(kubectl get pods  | awk '/^run-as-user/ {print \$1;exit}')"
    pressKeyToContinue
    message "====================================="

    printFile "${ABSOLUTE_BASEDIR}"/../notes/why-run-as-non-root.md
    message "====================================="

    pressKeyToContinue
}

function allowPrivilegeEscalation() {

  heading "3. allowPrivilegeEscalation"

  printFile "${ABSOLUTE_BASEDIR}"/../notes/priv-elevation.md

  subHeading "3.1 Escalate privileges"
  printAndRun "kubectl create deployment docker-sudo --image schnatterer/docker-sudo:0.1"
  message "====================================="

  run "kubectl rollout status deployment docker-sudo > /dev/null"
  message "====================================="

  printAndRun "kubectl exec \$(kubectl get pods  | awk '/docker-sudo/ {print \$1;exit}') -- id"
  pressKeyToContinue
  message "====================================="

  printAndRun "kubectl exec \$(kubectl get pods  | awk '/docker-sudo/ {print \$1;exit}') -- sudo id"
  pressKeyToContinue
  message "====================================="

  subHeading "3.2 Same with  \"allowPrivilegeEscalation: false\" ➡️  escalation fails"
  printFile "${ABSOLUTE_BASEDIR}"/05-deployment-allow-no-privilege-escalation.yaml
  pressKeyToContinue
  message "====================================="

  printAndRun "kubectl exec \$(kubectl get pods  | awk '/allow-no-privilege-escalation/ {print \$1;exit}') -- sudo id"
  pressKeyToContinue
  message "====================================="
}

function enableServiceLinks() {
  heading "4. enableServiceLinks"

  printFile "${ABSOLUTE_BASEDIR}"/../notes/service-links.md
  message "====================================="

  subHeading "4.1 Show service links"
  printAndRun "kubectl create service clusterip my-service --tcp=80:8080 || true"
  printAndRun "kubectl run tmp-env --image busybox:1.31.1-musl --command sleep 100000"
  pressKeyToContinue
  message "====================================="

  printAndRun "kubectl exec tmp-env -- env | sort"
  pressKeyToContinue
  message "====================================="

  subHeading "4.2 Disable service links"
  printAndRun "kubectl run tmp-env2 --image busybox:1.31.1-musl --overrides='{\"spec\": {\"enableServiceLinks\": false}}' --command sleep 100000"
  pressKeyToContinue
  message "====================================="

  printAndRun "kubectl exec tmp-env2 -- env"
  pressKeyToContinue
  message "====================================="
}

function activateSeccompProfile() {
  heading "5. Enable Seccomp default profile"

  printFile "${ABSOLUTE_BASEDIR}"/../notes/seccomp.md
  message "====================================="

  subHeading "5.1 No seccomp profile by default 😲"
  kubectlSilent create deployment nginx --image nginx:1.19.3
  printAndRun "kubectl exec \$(kubectl get pods  | awk '/nginx/ {print \$1;exit}') -- grep Seccomp /proc/1/status"
  pressKeyToContinue
  message "====================================="

  subHeading "5.2 Same with  default seccomp profile"
  printFile "${ABSOLUTE_BASEDIR}"/06-deployment-seccomp.yaml
  pressKeyToContinue
  message "====================================="

  printAndRun "kubectl get pod \$(kubectl get pods  | awk '/run-with-seccomp/ {print \$1;exit}')"
  pressKeyToContinue
  message "====================================="

  printAndRun "kubectl exec \$(kubectl get pods  | awk '/run-with-seccomp/ {print \$1;exit}') -- grep Seccomp /proc/1/status"
  pressKeyToContinue
  message "====================================="
}

function dropCapabilities() {
  heading "6. Drop Capabilities"
  printFile "${ABSOLUTE_BASEDIR}"/../notes/drop-caps.md
  message "====================================="

  subHeading "6.1 some images require capabilities"
  printFile "${ABSOLUTE_BASEDIR}"/07-deployment-run-without-caps.yaml
  pressKeyToContinue
  message "====================================="

  printAndRun "kubectl get pod \$(kubectl get pods  | awk '/^run-without-caps/ {print \$1;exit}')"
  pressKeyToContinue
  message "====================================="

  printAndRun "kubectl logs \$(kubectl get pods  | awk '/^run-without-caps/ {print \$1;exit}') "
  pressKeyToContinue
  message "====================================="

  message "How to find out which capabilities we need to add? Reproduce locally."
  printAndRun "docker run --rm --cap-drop ALL nginx:1.19.3"
  pressKeyToContinue
  message "====================================="

  message "Add first capability: CAP_CHOWN.\nNote: Stop running container with Ctrl + C to continue."
  printAndRun "docker run --rm --cap-drop ALL --cap-add CAP_CHOWN nginx:1.19.3"
  #printAndRun "docker run --rm --cap-drop ALL --cap-add CAP_CHOWN --cap-add CAP_NET_BIND_SERVICE nginx:1.19.3"
  #printAndRun "docker run --rm --cap-drop ALL --cap-add CAP_CHOWN --cap-add CAP_NET_BIND_SERVICE --cap-add SETGID nginx:1.19.3"
  #printAndRun "docker run --rm --cap-drop ALL --cap-add CAP_CHOWN --cap-add CAP_NET_BIND_SERVICE --cap-add SETGID --cap-add SETUID nginx:1.19.3"
  message "====================================="

  message "Continue adding capabilities until the container runs.\nFinally add the necessary caps to kubernetes"
  printFile "${ABSOLUTE_BASEDIR}"/08-deployment-run-with-certain-caps.yaml
  pressKeyToContinue
  message "====================================="

  printAndRun "kubectl get pod \$(kubectl get pods  | awk '/run-with-certain-caps/ {print \$1;exit}')"
  pressKeyToContinue
  message "====================================="

  subHeading "6.2 Image that runs without caps"
  printFile "${ABSOLUTE_BASEDIR}"/09-deployment-run-without-caps-unprivileged.yaml
  pressKeyToContinue
  message "====================================="

  printAndRun "kubectl get pod \$(kubectl get pods  | awk '/run-without-caps-unprivileged/ {print \$1;exit}')"
  pressKeyToContinue
  message "====================================="
}

function readOnlyRootFilesystem() {

  heading "7. readOnlyRootFilesystem"

  printFile "${ABSOLUTE_BASEDIR}"/../notes/readonly-filesystem.md
  message "====================================="

  kubectlSilent create deployment docker-sudo --image schnatterer/docker-sudo:0.1

  subHeading "7.1 Write to container's file system"
  printAndRun "kubectl exec \$(kubectl get pods  | awk '/docker-sudo/ {print \$1;exit}') -- sudo apt update"
  pressKeyToContinue
  message "====================================="

  subHeading "7.2 Same with  \"readOnlyRootFilesystem: true\" ➡️  fails to write to temp dirs"
  printFile "${ABSOLUTE_BASEDIR}"/10-deployment-read-only-fs.yaml
  pressKeyToContinue
  message "====================================="

  printAndRun "kubectl exec \$(kubectl get pods  | awk '/^read-only-fs/ {print \$1;exit}') -- sudo apt update"
  pressKeyToContinue
  message "====================================="

  subHeading "7.3 readOnlyRootFilesystem causes issues with other images"
  printFile "${ABSOLUTE_BASEDIR}"/11-deployment-nginx-read-only-fs.yaml
  pressKeyToContinue
  message "====================================="

  printAndRun "kubectl get pod \$(kubectl get pods  | awk '/failing-nginx-read-only-fs/ {print \$1;exit}')"
  pressKeyToContinue
  message "====================================="

  message "Not running. Let's check the logs"
  printAndRun "kubectl logs \$(kubectl get pods  | awk '/failing-nginx-read-only-fs/ {print \$1;exit}')"
  pressKeyToContinue
  message "====================================="

  message "How to find out which folders we need to mount?"
  printAndRun "nginxContainer=\$(docker run -d --rm nginx:1.19.3)"
  pressKeyToContinue
  printAndRun "docker diff \${nginxContainer}"
  run "docker rm -f \${nginxContainer} > /dev/null"
  pressKeyToContinue
  message "====================================="

  message "Mount those dirs as as emptyDir!"
  printFile "${ABSOLUTE_BASEDIR}"/12-deployment-nginx-read-only-fs-empty-dirs.yaml
  pressKeyToContinue
  message "====================================="

  printAndRun "kubectl get pod \$(kubectl get pods  | awk '/empty-dirs-nginx-read-only-fs/ {print \$1;exit}')"
  pressKeyToContinue
  message "====================================="

}

function allAtOnce() {
  heading "8. An example that implements all good practices at once"
  pressKeyToContinue

  printFile "${ABSOLUTE_BASEDIR}"/13-deployment-all-at-once.yaml
  pressKeyToContinue
  message "====================================="

  printAndRun "kubectl get pod \$(kubectl get pods  | awk '/all-at-once/ {print \$1;exit}')"
  pressKeyToContinue
  message "====================================="

  printAndRun "kubectl port-forward \$(kubectl get pods  | awk '/all-at-once/ {print \$1;exit}') 8080 > /dev/null& "
  run "wget -O- --retry-connrefused --tries=30 -q --wait=1 localhost:8080 > /dev/null"
  pressKeyToContinue
  printAndRun "curl localhost:8080"
  pressKeyToContinue
  message "====================================="

  run "jobs > /dev/null && kill %1"
  pressKeyToContinue
  message "====================================="
}

main "$@"
