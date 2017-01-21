#!/usr/bin/env bash
#
# Cleanup setup script.

WORKER_NAME="rancher-agent"

echo "I: removing all docker-machines created by setup.sh"
for machine in $(docker-machine ls --format '{{ .Name }}' | tr '\r\n' ' '); do
  if [[ -z "${machine}" ]]; then
    echo "W: No Machines Found."
    break;
  fi

  echo " -> ${machine}"

  echo " --> stopping ${machine}"
  docker-machine stop "${machine}" 1>/dev/null || echo "W: Failed to stop '${machine}'"

  echo " --> removing ${machine}"
  docker-machine rm -y "${machine}" 1>/dev/null
  if [[ $? -ne 0 ]] ; then
    echo "E: Failed to remove '${machine}'"
    exit 1
  fi
done

echo "I: Cleaning up docker ..."
docker stop rancher-server
docker rm rancher-server

# TODO docker-machine certs without breaking anything.

echo -n "Delete ./rancher/mysql? (Rancher Database) [Y/n]: "
read CONFIRM_DELETE

CONFIRM_DELETE_LOWER="$(echo ${CONFIRM_DELETE} | tr '[:upper:]' '[:lower:]')"

# Convert
if [[ "$CONFIRM_DELETE_LOWER" == "y" ]]; then
  rm -r ./rancher/mysql
  echo "--> Deleted."
else
  echo "--> Not Deleting."
fi

echo -n "Delete agent information? (Fixes Agent Duplication) [Y/n]: "
read CONFIRM_DELETE

CONFIRM_DELETE_LOWER="$(echo ${CONFIRM_DELETE} | tr '[:upper:]' '[:lower:]')"

# Convert
if [[ "$CONFIRM_DELETE_LOWER" == "y" ]]; then
  rm -r ./storage ./agents
  echo "--> Deleted."
else
  echo "--> Not Deleting."
fi

echo "I: Finished, run './setup.sh' again to restart."
