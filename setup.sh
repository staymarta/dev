#!/usr/bin/env bash
#
# (c) 2017 StayMarta

DIR="$(cd  $(dirname ${BASH_SOURCE[0]}); pwd)"

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

INFO "Adding git hooks"
cp -v "${DIR}/.setup/git-hooks/"* "${DIR}/.git/hooks"

INFO "Extracting service snapshots ..."


# Extract available snapshots
if [[ -e "${DIR}/snapshots" ]]; then
  pushd "${DIR}/snapshots" 1>/dev/null
    mkdir "../storage" 2>/dev/null

    # Extract all available snapshots.
    for file in $(ls);
    do
      if [[ -z "$file" ]]; then
        WARN "W: No snapshots available"
        exit 1
      fi

      SERVICENAME="`echo ${file} | cut -d "_" -f 2 | cut -d "." -f 1`"

      if [[ -e "../storage/${SERVICENAME}" ]]; then
        WARN -n "${SERVICENAME} already exists. Press Enter to Continue, or ^C to quit. "
        read
        rm -rf "../storage/${SERVICENAME}"
      fi

      echo " --> restore ${SERVICENAME}"
      7z x $file -o../storage 1>/dev/null
    done
  popd 1>/dev/null
else
  INFO "No snapshots found."
fi
