#!/usr/bin/env bash

out() {
  echo "--> $*"
}

out "Running in $(pwd)"

pushd "storage"
for file in $(ls);
do
  SNAPSHOT_FILE="snapshot_$file.7z"

  out "snapshot of ${file}"

  if [[ -e "${SNAPSHOT_FILE}" ]]; then
    out "remove stale snapshot of ${file}"
    rm -v "${SNAPSHOT_FILE}"
  fi

  7z a "${SNAPSHOT_FILE}" $file
done
