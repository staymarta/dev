#!/usr/bin/env bash

# SERVER
export SERVER_IP="127.0.0.1"
export SERVER_DOCKER_IMAGE="rancher/server:stable"

# WORKERS
export WORKER_NAME="rancher-agent-"
export WORKER_MEM="2048"
export WORKER_DISKSIZE="20000" # 20GB
export WORKER_CPU="2"
export WORKER_AGENT="rancher/agent:v1.1.2"
export WORKER_COUNT=2
export WORKER_IP_BASE="192.168.99.1"

# IP CONFIG
export WORKER_1_IP="192.168.99.10"
export WORKER_2_IP="192.168.99.11"
