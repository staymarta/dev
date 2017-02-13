#!/usr/bin/env bash
#
# Cleanup setup script.

. ./.setup/config.sh

INFO "removing all docker-machines created by setup.sh"
for machine in $(docker-machine ls --format '{{ .Name }}' | tr '\r\n' ' '); do
  if [[ -z "${machine}" ]]; then
    WARN "No Machines Found."
    break;
  fi

  SUB "stopping ${machine}"
  docker-machine stop "${machine}" 1>/dev/null || echo "W: Failed to stop '${machine}'"

  SUB "removing ${machine}"
  docker-machine rm -y "${machine}" 1>/dev/null
  if [[ $? -ne 0 ]] ; then
    ERROR "Failed to remove '${machine}'"
    exit 1
  fi
done

INFO "Cleaning up docker ..."
docker stop rancher-server
docker rm rancher-server

# TODO docker-machine certs without breaking anything.

WARN -n "Delete ./rancher/mysql? (Rancher Database) [Y/n]: "
read CONFIRM_DELETE

CONFIRM_DELETE_LOWER="$(echo ${CONFIRM_DELETE} | tr '[:upper:]' '[:lower:]')"

# Convert
if [[ "$CONFIRM_DELETE_LOWER" == "y" ]]; then
  rm -r ./rancher/mysql
  SUB "Deleted."
else
  SUB "Not Deleting."
fi

WARN -n "Delete agent information? (Fixes Agent Duplication) [Y/n]: "
read CONFIRM_DELETE

CONFIRM_DELETE_LOWER="$(echo ${CONFIRM_DELETE} | tr '[:upper:]' '[:lower:]')"

# Convert
if [[ "$CONFIRM_DELETE_LOWER" == "y" ]]; then
  sudo rm -r ./agents
  SUB "Deleted."
else
  SUB "Not Deleting."
fi

INFO "Finished, run './setup.sh' again to restart."
