#!/bin/sh

set -eu

user=$1
address=$2
private_key=$3
public_key=$4

SCRIPT_DIR=$(dirname $0)

playbooks=("setup_nginx.yml" "setup_ufw.yml")
for playbook in "${playbooks[@]}"; do
  ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
    --user "${user}" \
    --inventory "${address}," \
    --private-key "${private_key}" \
    --e "pub_key=${public_key}" \
    "${SCRIPT_DIR}/${playbook}"
done

