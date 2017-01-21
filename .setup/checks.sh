#!/usr/bin/env bash

echo "I: running pre-checks ..."

if [[ "$(uname)" == "Darwin" ]]; then
  # Check for brew.
  if [[ ! -e "/usr/local/bin/brew" ]]; then
    echo "I: Homebrew not found, would you like me to install it? [Y/n]: "
    read CONFIRM

    CONFIRM_LOWER="$(echo ${CONFIRM} | tr '[:upper:]' '[:lower:]')"

    if [[ "${CONFIRM_LOWER}" != "y" ]]; then
      echo "E: not installing..."
      exit 10
    fi

    echo "I: Installing brew ..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" || exit 10
  fi

  # Check for docker
  if [[ ! -e "/usr/local/bin/docker" ]]; then
    echo "E: Please install Docker. (for Mac)"
    exit 10
  fi

  # Check for docker
  if [[ ! -e "/usr/local/bin/7z" ]]; then
    echo "I: Installing p7zip ..."
    brew install p7zip
  fi

  # Check for docker-machine
  if [[ ! -e "/usr/local/bin/docker-machine" ]]; then
    echo "I: docker-machine not found, would you like me to install it?"
    read CONFIRM

    CONFIRM_LOWER="$(echo ${CONFIRM} | tr '[:upper:]' '[:lower:]')"

    if [[ "${CONFIRM_LOWER}" != "y" ]]; then
      echo "E: not installing..."
      exit 10
    fi

    echo "I: Installing docker-machine ..."
    brew install docker-machine || exit 10

    exit 10
  fi
else # *nix or cygwin
  echo "IMPORTANT: Not MacOS, can\'t check for deps."
fi

VBoxManage 1>/dev/null 2>/dev/null || echo "E: Can\'t run VBoxManage. Please make sure it's in PATH. $(exit 10)"

echo "I: checks succedded."
