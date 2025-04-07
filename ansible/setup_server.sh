#!/bin/sh

set -eu

user=$1
address=$2
private_key=$3
public_key=$4

SCRIPT_DIR=$(dirname $0)

function perform_ansible_playbook {
  ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
    --user "${user}" \
    --inventory "${address}," \
    --private-key "${private_key}" \
    --e "pub_key=${public_key}" \
    "${SCRIPT_DIR}/$1"
}

perform_ansible_playbook setup_nginx.yml
perform_ansible_playbook setup_ufw.yml
