#!/bin/bash

enm_namespace=$1
ingress_host=$2
helm_package=$3
storage_class=$4

function usage
{
  echo ""
  echo "Usage:"
  echo "     <enm_namespace> <ingress_host> <helm_package> <storage_class>"
  echo ""
  exit 1
}

if [[ -z "$storage_class" ]]; then
  storage_class="nfs-$enm_namespace"
fi

if [[ -z "$enm_namespace" || -z "$ingress_host" || -z "$helm_package" ]]; then
  usage
fi

echo "Installing Helm Package Using below parameters:"
echo " ENM namespace  = $enm_namespace"
echo " Ingress Host   = $ingress_host"
echo " Helm package   = $helm_package"
echo " Storage class   = $storage_class"
echo ""

helm3 install adu-watcher \
--set ingress.tls[0].hosts[0]="$ingress_host" \
--set ingress.hosts[0].host="$ingress_host" \
--set ingress.hosts[0].paths[0]=/watcher/ \
--set persistence.persistentVolumeClaim.storageClassName="$storage_class" \
--namespace="$enm_namespace" \
"$helm_package"
