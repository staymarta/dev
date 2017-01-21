#!/usr/bin/env bash

echo "W: Please run 'setup.sh' if you haven't already"

echo "Starting developer env ..."
echo "I: Starting 'rancher-server' container ..."
docker start rancher-server

echo "I: Starting rancher-agent(s) ..."
for machine in $(docker-machine ls --format '{{ .Name }}' | tr '\r\n' ' '); do
  if [[ -z "${machine}" ]]; then
    echo "W: No Machines Found."
    break;
  fi

  echo " --> ${machine}"
  docker-machine start "${machine}"
  if [[ $? -ne 0 ]]; then
    echo "E: Failed to start '${machine}'"
    exit 1
  fi
done
