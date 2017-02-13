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

echo "Root priviliges are needed to run this script. If prompted, please enter your password"

sudo echo >/dev/null # Attempt to get sudo early on.

DIR="$(cd  $(dirname ${BASH_SOURCE[0]}); pwd)"
ID="$(id -u)"
GROUP="$(id -g)"

chmod +x ./.setup/*.sh

# Load our config.
. ./.setup/config.sh

# Ensure we can actually run this.
. ./.setup/checks.sh

if [[ ! -e "./rancher" ]]; then
  ERROR "Please run in env folder."
  exit 20
fi

if [[ ! -e "./rancher/mysql" ]]; then
    if [[ ! -e "./rancher/mysql.zip" ]]; then
      ERROR "Missing rancher snapshot."
      exit 1
    fi

    INFO "Extracting rancher snapshot ..."
    unzip -q ./rancher/mysql -drancher/
fi

INFO "This will take awhile, go grab some coffee! ☕️"

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

INFO "Adding git hooks"
cp -v ./devops/git-hooks/* ./.git/hooks

INFO "Pulling server image: ${SERVER_DOCKER_IMAGE}"
docker pull ${SERVER_DOCKER_IMAGE}

INFO "Starting Rancher Server"
if [ "$(curl -s http://${SERVER_IP}:8080/ping)" != "pong" ]; then
  docker run --name rancher-server -d -v $(PWD)/rancher/mysql:/var/lib/mysql -p 8080:8080 ${SERVER_DOCKER_IMAGE}

  INFO -n "(${SERVER_IP}) Waiting for server to start"
  while sleep 5; do
    if [ "$(curl -s http://${SERVER_IP}:8080/ping)" = "pong" ]; then
      echo " OK"
      break
    fi
    echo -n "."
  done
else
  INFO "Already Running."
fi

mkdir -p "${DIR}/storage"
mkdir -p "${DIR}/agents"

################################################################################
# Mac NFS setup
#

INFO "Share path: '${SHARE_PATH}'"
NFSCNF="nfs.server.mount.require_resv_port = 0"
if ! $(grep "$NFSCNF" /etc/nfs.conf > /dev/null 2>&1); then
  INFO "[d4m-nfs] Set the NFS nfs.server.mount.require_resv_port value."
  echo -e "\nnfs.server.mount.require_resv_port = 0\n" | sudo tee -a /etc/nfs.conf
fi

NFSEXP="\"${SHARE_PATH}\" -alldirs -mapall=${ID}:${GROUP} 127.0.0.1"

grep "${NFSEXP}" /etc/exports 1>/dev/null 2>/dev/null
# Determine if it's already done.
if [[ $? -ne 0 ]]; then
  INFO "Writing to /etc/exports"
  EXPORTS="$EXPORTS\n$NFSEXP"
  echo -e "$EXPORTS\n" | sudo tee -a /etc/exports
fi

INFO "[d4m-nfs] Start and restop nfsd, for some reason restart is not as kind."
sudo nfsd enable 2>/dev/null
sudo nfsd stop && sudo nfsd start

INFO -n "[d4m-nfs] Wait until NFS is setup ..."
while ! rpcinfo -u localhost nfs > /dev/null 2>&1; do
  echo -n "."
  sleep .25
done
echo " OK"

################################################################################

# Create workers.
CREATED_WORKERS=0
until [[ ${CREATED_WORKERS} == ${WORKER_COUNT} ]]; do
  CREATED_WORKERS=$((CREATED_WORKERS+1))
  ./.setup/create-worker.sh ${CREATED_WORKERS}
done

INFO "Configuring rancher-cli"
mkdir -p "$HOME/.rancher"
echo '{"accessKey":"D7015BE425412716307C","secretKey":"3iCBhWCzwAt7jnQ66UkbEPQt54D9bcJ1zn4wgFBt","url":"http://127.0.0.1:8080/v2-beta/schemas","environment":"1a17"}' > "$HOME/.rancher/cli.json"

echo "Done! Rancher is running at http://${SERVER_IP}:8080"
