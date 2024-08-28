#!/bin/bash

enm_namespace=$1
log_file=$2
separator='=============================================================='
data_dir="/var/adu/data"

if [[ "${log_file}" ]]; then
  rm /var/adu/data/"${log_file}"
fi

echo "${separator}" >> "${data_dir}/${log_file}"
echo $(hostname) >> "${data_dir}/${log_file}"
echo "${separator}" >> "${data_dir}/${log_file}"
cat /usr/local/tomcat/logs/"${log_file}" >> "${data_dir}/${log_file}"

other_pod=$(/usr/local/bin/kubectl get pods -n "${enm_namespace}" | grep adu | grep -v $(hostname) | awk '{print $1}')

kubectl cp "${enm_namespace}/${other_pod}":/usr/local/tomcat/logs/${log_file} /tmp/${log_file}

echo "${separator}" >> "${data_dir}/${log_file}"
echo "${other_pod}" >> "${data_dir}/${log_file}"
echo "${separator}" >> "${data_dir}/${log_file}"
cat /tmp/${log_file} >> "${data_dir}/${log_file}"

rm /tmp/${log_file}
