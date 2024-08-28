#!/bin/bash

function main() {
    case "$command" in
        read_grace_period)
            echo $(read_grace_period $enm_namespace)
            ;;
        read_psv)
            echo $(read_psv $enm_namespace)
            ;;
    esac
}

function read_grace_period() {
    pod_name=$(/usr/local/bin/kubectl get pods -n "$enm_namespace" | grep filetransferservice | awk '{print $1}' | head -n 1)
    grace_period=$(/usr/local/bin/kubectl get pods -n "$enm_namespace" "$pod_name"  -o jsonpath={.spec.terminationGracePeriodSeconds})
    echo "$grace_period"
}

function read_psv(){
    psv=$(/usr/local/bin/kubectl get cm eric-enm-version-configmap -n "$enm_namespace" -o jsonpath={.metadata.annotations."ericsson\.com/product-set-version"})
    echo "$psv"
}

command=$1
enm_namespace=$2

main $command $enm_namespace
