#!/usr/bin/env bash
#
# (c) 2017 StayMarta
#
# TODO: Less code repetition.

INFO "running pre-checks ..."

if [[ "$(uname)" == "Darwin" ]]; then
  # Check for brew.
  if [[ ! -e "/usr/local/bin/brew" ]]; then
    INFO "Homebrew not found, would you like me to install it? [Y/n]: "
    read CONFIRM

    CONFIRM_LOWER="$(echo ${CONFIRM} | tr '[:upper:]' '[:lower:]')"

    if [[ "${CONFIRM_LOWER}" != "y" ]]; then
      ERROR "not installing..."
      exit 10
    fi

    INFO "Installing brew ..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" || exit 10
  fi

  # Check for docker
  if [[ ! -e "/usr/local/bin/docker" ]]; then
    ERROR "Please install Docker. (for Mac)"
    exit 10
  fi

  # Check for docker
  if [[ ! -e "/usr/local/bin/7z" ]]; then
    INFO "Installing p7zip ..."
    brew install p7zip
  fi

  # Check for docker-machine
  if [[ ! -e "/usr/local/bin/docker-machine" ]]; then
    INFO "docker-machine not found, would you like me to install it?"
    read CONFIRM

    CONFIRM_LOWER="$(echo ${CONFIRM} | tr '[:upper:]' '[:lower:]')"

    if [[ "${CONFIRM_LOWER}" != "y" ]]; then
      ERROR "not installing..."
      exit 10
    fi

    INFO "Installing docker-machine ..."
    brew install docker-machine
    brew link docker-machine
  fi
else # *nix or cygwin
  echo "IMPORTANT: Not MacOS, can\'t check for deps."
fi

VBoxManage 1>/dev/null 2>/dev/null || ERROR "Can\'t run VBoxManage. Please make sure it's in PATH. $(exit 10)"
docker-machine 1>/dev/null 2>/dev/null || ERROR "Can'\t run docker-machine. Please make sure it's in PATH. $(exit 10)"

INFO "checks succedded."
