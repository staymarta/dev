#!/usr/bin/env bash

echo "W: Please run 'setup.sh' if you haven't already"

echo "Starting developer env ..."
echo "--> starting 'rancher-server'"
docker start rancher-server

echo "--> starting 'rancher-agent' machine"
docker-machine start rancher-agent
