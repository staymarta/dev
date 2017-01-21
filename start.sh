#!/usr/bin/env bash

. ./.setup/config.sh

WARN "Please run 'setup.sh' if you haven't already"

echo "Starting developer env ..."
INFO "Starting 'rancher-server' container ..."
docker start rancher-server

INFO "Starting rancher-agent(s) ..."
for machine in $(docker-machine ls --format '{{ .Name }}' | tr '\r\n' ' '); do
  if [[ -z "${machine}" ]]; then
    WARN "No Machines Found."
    break;
  fi

  SUB "${machine}"
  docker-machine start "${machine}"
  if [[ $? -ne 0 ]]; then
    ERROR "Failed to start '${machine}'"
    exit 1
  fi
done
