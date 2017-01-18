#!/usr/bin/env bash

out() {
  echo "--> $*"
}

out "Running in $(pwd)"

pushd "storage"

out "Removing stale snapshots"
rm -rvf "*.7z"

for file in $(ls);
do
  SNAPSHOT_FILE="snapshot_$file.7z"

  out "snapshot of ${file}"

  7z a "${SNAPSHOT_FILE}" $file 1>/dev/null
  mv -v ${SNAPSHOT_FILE} "../snapshots"
done

popd
