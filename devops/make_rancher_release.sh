#!/usr/bin/env bash

pushd "../rancher"

echo "I: creating mysql.zip"
7z a mysql_staging.zip mysql || exit 20
rm mysql.zip
mv -v mysql_staging.zip mysql.zip

popd
