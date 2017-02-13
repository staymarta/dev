#!/usr/bin/env bash

out() {
  echo "--> $*"
}

out "Running in $(pwd)"

mkdir -p "snapshots"

pushd "snapshots" 1>/dev/null

out "Cleaning up snapshots dir ..."
rm -rv *.7z
popd 1>/dev/null

pushd "storage"

  out "Removing stale snapshots"
  rm -rvf "*.7z"

  for file in $(ls);
  do
    if [[ "$file" != "tmp" ]]; then # Ignore tmp directory.
      SNAPSHOT_FILE="snapshot_$file.7z"

      if [[ ! -d "$file" ]]; then
        out "ignoring non-directory: '$file'"
      else
        out "snapshot of ${file}"

        7z a "${SNAPSHOT_FILE}" $file 1>/dev/null
        mv -v ${SNAPSHOT_FILE} "../snapshots"
      fi
    fi
  done

popd

out "snapshots created"
