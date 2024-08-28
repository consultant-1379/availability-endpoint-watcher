#!/bin/bash

neo_pod=$1

pod_ip=$(/usr/local/bin/kubectl get pod "${neo_pod}" -o wide | grep "${neo_pod}" | awk -F' ' '{print $6}' 2>&1)

if [[ $pod_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "${pod_ip}"
else
    echo "fail"
fi

