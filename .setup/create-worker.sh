#!/usr/bin/env bash

. ./.setup/config.sh

NUM=$1

if [[ -z "${NUM}" ]]; then
  WARN "Invoked without worker number, assuming 1. Data loss may occur."
  echo "Press ^C to quit or wait 5 seconds."
  sleep 5
fi

WORKER_NAME="${WORKER_NAME}${NUM}"

# Check if the machine already exists.
docker-machine inspect "${WORKER_NAME}" 2>/dev/null 1>/dev/null
if [[ $? == 0 ]] ; then
  ERROR "Machine '${WORKER_NAME}' already exists."
  exit 1
fi

# Create the machine.
INFO "Creating worker '${WORKER_NAME}'..."
docker-machine create ${WORKER_NAME} --driver virtualbox --virtualbox-disk-size="${WORKER_DISKSIZE}" \
  --virtualbox-cpu-count "${WORKER_CPU}" --virtualbox-memory "${WORKER_MEM}"

# Copy the init script + generated IP.
TEMPFILE="$(mktemp)"
echo "#!/usr/bin/env bash" > "${TEMPFILE}"

# Dynamically link to variable name.
DYNREFLINK="WORKER_${NUM}_IP"

if [[ ! -z "${!DYNREFLINK}" ]]; then
  INFO "Overriding IP"
  echo "IP='${!DYNREFLINK}'" >> "${TEMPFILE}"
else
  echo "IP='192.168.99.10${NUM}'" >> "${TEMPFILE}"
fi

echo "" >> "${TEMPFILE}"

INFO -n "Configuring worker IP ... "
cat "${TEMPFILE}" ./devops/init.sh | docker-machine ssh ${WORKER_NAME} sudo tee /var/lib/boot2docker/bootsync.sh > /dev/null
docker-machine ssh ${WORKER_NAME} sudo chmod +x /var/lib/boot2docker/bootsync.sh
echo "OK"

# Put the new IP into effect.
echo " --> Stopping worker ..."
docker-machine stop ${WORKER_NAME}

# TODO: Volume discovery.
INFO "Configuring worker to allow storage persistance. ... "

# Preemptively create folder(s).
mkdir -p "$(pwd)/agents/${WORKER_NAME}"
mkdir -p "$(pwd)/storage/${WORKER_NAME}"

# Create shared folders
VBoxManage sharedfolder add ${WORKER_NAME} --name "agent" --hostpath "$(pwd)/agents/${WORKER_NAME}"
VBoxManage sharedfolder add ${WORKER_NAME} --name "storage" --hostpath "$(pwd)/storage/${WORKER_NAME}"

echo " --> Starting worker ..."
docker-machine start ${WORKER_NAME}

echo " --> Regenerating worker certs ..."
docker-machine regenerate-certs -f ${WORKER_NAME}

# Always consistently get IP.
WORKER_IP=$(docker-machine ssh ${WORKER_NAME} ip addr show eth1 | grep inet | awk '{print $2}' | awk -F '/' '{print $1}' | head -n1)

INFO "(${WORKER_NAME}->${WORKER_IP}) pulling ${WORKER_AGENT}"
docker-machine ssh docker pull ${WORKER_AGENT}

INFO "(${WORKER_NAME}->${WORKER_IP}) fetching agent string..."
PROJECT_ID=$(curl -s -X GET http://${SERVER_IP}:8080/v1/projects | python -c'import json,sys;print(json.load(sys.stdin)["data"][0]["id"])')
TOKEN_ID=$(curl -s -X POST http://${SERVER_IP}:8080/v1/projects/${PROJECT_ID}/registrationtokens | python -c'import json,sys; print(json.load(sys.stdin))')
URL=$(curl -s -X GET http://${SERVER_IP}:8080/v1/projects/${PROJECT_ID}/registrationtokens | python -c'import json,sys; print(json.load(sys.stdin)["data"][0]["registrationUrl"])')
COMMAND="sudo docker run -e CATTLE_AGENT_IP="${WORKER_IP}" -d --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/rancher:/var/lib/rancher ${WORKER_AGENT} ${URL}"

if [[ -z "${URL}" ]]; then
  ERROR "Failed to determine rancher-agent status."
  exit 1
fi

INFO "(${WORKER_NAME}) installing rancher-agent ..."
docker-machine ssh ${WORKER_NAME} ${COMMAND}
