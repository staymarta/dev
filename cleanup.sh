#!/usr/bin/env bash
#
# Cleanup setup script.

echo "I: removing all docker-machines created by setup.sh"
docker-machine stop rancher rancher-agent
docker-machine rm rancher rancher-agent

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
  rm -r ./persist
  echo "--> Deleted."
else
  echo "--> Not Deleting."
fi

echo "I: Finished, run './setup.sh' again to restart."
