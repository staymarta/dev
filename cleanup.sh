#!/usr/bin/env bash
#
# Cleanup setup script.

echo "I: removing all docker-machines created by setup.sh"
docker-machine stop rancher rancher-agent
docker-machine rm rancher rancher-agent
