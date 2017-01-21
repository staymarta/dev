#!/usr/bin/env bash
# (c) 2016 StayMarta
#
# Error Codes: ALWAYS CHECK ERROR OUTPUT.
# - 1   General Error.
# - 25  Server Creation Failed.
# - 20  Wrong DIR.
# - 10  Missing reqs
# - 15  Client creation failed.
### CONFIG

chmod +x ./.setup/*.sh

# Load our config.
. ./.setup/config.sh

# Ensure we can actually run this.
. ./.setup/checks.sh

if [[ ! -e "./rancher" ]]; then
  echo "E: Please run in env folder."
  exit 20
fi

if [[ ! -e "./rancher/mysql" ]]; then
    if [[ ! -e "./rancher/mysql.zip" ]]; then
      echo "E: Missing rancher snapshot."
      exit 1
    fi

    echo "I: Extracting rancher snapshot ..."
    unzip -q ./rancher/mysql -drancher/
fi

echo "I: Extracting machine agents."
pushd "snapshots" 1>/dev/null
mkdir "../storage" 2>/dev/null

# Extract all available snapshots.
for file in $(ls);
do
  MACHINENAME="`echo ${file} | cut -d "_" -f 2 | cut -d "." -f 1`"

  if [[ -e "../storage/${MACHINENAME}" ]]; then
    echo "E: ${MACHINENAME} already exists. Press Enter to Continue, or ^C to quit. "
    read
    rm -rf "../storage/${MACHINENAME}"
  fi

  echo " --> restore ${MACHINENAME}"
  7z x $file -o../storage 1>/dev/null
done

popd 1>/dev/null

echo "I: Adding git hooks"
cp -v ./devops/git-hooks/* ./.git/hooks

echo "I: Pulling server image: ${SERVER_DOCKER_IMAGE}"
docker pull ${SERVER_DOCKER_IMAGE}

echo "I: Starting Rancher Server"
if [ "$(curl -s http://${SERVER_IP}:8080/ping)" != "pong" ]; then
  docker run --name rancher-server -d -v $(PWD)/rancher/mysql:/var/lib/mysql -p 8080:8080 ${SERVER_DOCKER_IMAGE}

  echo -n "I: (${SERVER_IP}) Waiting for server to start ."
  while sleep 5; do
    if [ "$(curl -s http://${SERVER_IP}:8080/ping)" = "pong" ]; then
      echo " OK"
      break
    fi
    echo -n "."
  done
else
  echo "I: Already Running."
fi

CREATED_WORKERS=0
until [[ ${CREATED_WORKERS} == ${WORKER_COUNT} ]]; do
  CREATED_WORKERS=$((CREATED_WORKERS+1))
  ./.setup/create-worker.sh ${CREATED_WORKERS}
done

echo "Done! Rancher is running at http://${SERVER_IP}:8080"
