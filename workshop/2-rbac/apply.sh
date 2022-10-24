#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

BASEDIR=$(dirname $0)
ABSOLUTE_BASEDIR="$( cd "${BASEDIR}" && pwd )"

source "${ABSOLUTE_BASEDIR}"/../cluster-utils.sh
source "${ABSOLUTE_BASEDIR}"/../interactive-utils.sh

function main() {

    confirm "Preparing demo in kubernetes cluster '$(kubectl config current-context)'." 'Continue? y/n [n]' \
     || exit 0
     
    # Make sure we're in a namespace that does not have any netpols
    kubectlIdempotent create namespace sec-ctx
    kubectl config set-context $(kubectl config current-context) --namespace=sec-ctx
    kubectl apply -f "${ABSOLUTE_BASEDIR}"/demo
}

main "$@"
