#!/usr/bin/env bash

function GENERIC {
  local PREFIX=$1
  local ARG="-e"

  # We don't care about prefix now.
  shift
  if [[ "$1" == "-n" ]]; then
    ARG="-en"
    shift # shift to remove -n
  fi

  echo "${ARG}" "${PREFIX}$*" "\x1B[0m" # Prefix, Text, Color Reset.
}

# I: <etc>
function INFO {
  local PREFIX="\x1B[0;94mI: "

  GENERIC "${PREFIX}" $*
}

# --> <etc>
function SUB {
  local PREFIX="\x1B[0;90m --> "

  GENERIC "${PREFIX}" $*
}

# W: <etc>
function WARN {
  local PREFIX="\x1B[0;93mW: "

  GENERIC "${PREFIX}" $*
}

# E: <etc>
function ERROR {
  local PREFIX="\x1B[0;41mE: "

  GENERIC "${PREFIX}" $*
}

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
