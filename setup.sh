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
#SERVER_MEM="1024"
#SERVER_CPU="2"
#SERVER_DISKSIZE="20000" # 20GB
#SERVER_HOST="rancher"
#SERVER_IMAGE="https://github.com/rancher/os/releases/download/v0.7.1/rancheros.iso"
SERVER_IP="127.0.0.1"
SERVER_DOCKER_IMAGE="rancher/server:stable"

WORKER_NAME="rancher-agent"
WORKER_MEM="2048"
WORKER_DISKSIZE="20000" # 20GB
WORKER_CPU="2"
WORKER_AGENT="rancher/agent:v1.1.2"
WORKER_IMAGE="https://github.com/boot2docker/boot2docker/releases/download/v1.12.6/boot2docker.iso"
WORKER_COUNT="2" # TODO

# TODO: try to support xhyve again.
#
# Check for native docker-machine-driver-xhyve support.
#if [[ ! -e "/usr/local/bin/docker-machine-driver-xhyve" ]]; then
#  echo "I: Installing docker-machine-driver-xhyve"
#  brew update
#  brew install docker docker-compose docker-machine
#else
#  echo "I: docker-machine-driver-xhyve already installed."
#fi
#echo "--> Correcting permissions of docker-machine-driver-xhyve"
#sudo chown root:wheel /usr/local/bin/docker-machine-driver-xhyve
#sudo chmod u+s /usr/local/bin/docker-machine-driver-xhyve

# echo "I: Creating docker-machine for server..."
# Old Server in a VM.
#
# docker-machine create ${SERVER_HOST} --driver virtualbox --virtualbox-disk-size="${SERVER_DISKSIZE}" \
#  --virtualbox-cpu-count "${SERVER_CPU}" --virtualbox-memory "${SERVER_MEM}" \
#  --virtualbox-boot2docker-url="${SERVER_IMAGE}"
#
# Get Server IP.
# SERVER_IP="$(docker-machine ssh ${SERVER_HOST} ip addr show eth1 | grep inet | awk '{print $2}' | awk -F '/' '{print $1}' | head -n1)"

# Old Server in a VM way.
#
# echo "I: Starting Rancher Server"
# if [ "$(curl -s http://${SERVER_IP}:8080/ping)" != "pong" ]; then
#  docker-machine ssh ${SERVER_HOST} docker run -d -v $(PWD)/rancher/mysql:/var/lib/mysql --restart=unless-stopped -p 8080:8080 rancher/server
#
#   echo -n "I: (${SERVER_IP}) Waiting for server to start ."
#   while sleep 5; do
#       if [ "$(curl -s http://${SERVER_IP}:8080/ping)" = "pong" ]; then
#           echo Success
#           break
#       fi
#       echo -n "."
#   done
# else
#   echo "I: Already running."
# Mac OSX checks
# fi


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

################################################################################
# WORKER

echo "I: Creating worker..."
docker-machine create ${WORKER_NAME} --driver virtualbox --virtualbox-disk-size="${WORKER_DISKSIZE}" \
  --virtualbox-cpu-count "${WORKER_CPU}" --virtualbox-memory "${WORKER_MEM}" \
  --virtualbox-boot2docker-url="${WORKER_IMAGE}"

# TODO Copy over this "init" script
echo -n "I: Configuring worker IP ... "
echo " \
  echo 'I: changing eth1 ip ...'; \
  cat /var/run/udhcpc.eth1.pid | xargs sudo kill; \
  ifconfig eth1 192.168.99.10 netmask 255.255.255.0 broadcast 192.168.99.255 up; \
  ip addr; \
  echo 'I: mounting rancher data to persist.'; \
  mkdir -vp /var/lib/rancher; \
  mount -t vboxsf '${WORKER_NAME}-persist' /var/lib/rancher; \
  echo 'mount returned $?' \
" | docker-machine ssh ${WORKER_NAME} sudo tee /var/lib/boot2docker/bootsync.sh > /dev/null
docker-machine ssh ${WORKER_NAME} sudo chmod +x /var/lib/boot2docker/bootsync.sh
echo "OK"

# Put the new IP into effect.
echo " --> Stopping worker ..."
docker-machine stop ${WORKER_NAME}

# TODO: Volume discovery.
echo -n "I: Configuring worker to persist some data ... "
mkdir -p "$(pwd)/persist/${WORKER_NAME}/agent"
VBoxManage sharedfolder add ${WORKER_NAME} --name "${WORKER_NAME}-persist" --hostpath "$(pwd)/persist/${WORKER_NAME}/agent"
echo "OK"

echo " --> Starting worker ..."
docker-machine start ${WORKER_NAME}

echo " --> Regenerating worker certs ..."
docker-machine regenerate-certs -f ${WORKER_NAME}

# Always consistently get IP.
WORKER_IP=$(docker-machine ssh ${WORKER_NAME} ip addr show eth1 | grep inet | awk '{print $2}' | awk -F '/' '{print $1}' | head -n1)

echo "I: (${WORKER_NAME}->${WORKER_IP}) pulling ${WORKER_AGENT}"
docker-machine ssh docker pull ${WORKER_AGENT}

echo "I: (${WORKER_NAME}->${WORKER_IP}) fetching agent string..."
PROJECT_ID=$(curl -s -X GET http://${SERVER_IP}:8080/v1/projects | python -c'import json,sys;print(json.load(sys.stdin)["data"][0]["id"])')
TOKEN_ID=$(curl -s -X POST http://${SERVER_IP}:8080/v1/projects/${PROJECT_ID}/registrationtokens | python -c'import json,sys; print(json.load(sys.stdin))')
URL=$(curl -s -X GET http://${SERVER_IP}:8080/v1/projects/${PROJECT_ID}/registrationtokens | python -c'import json,sys; print(json.load(sys.stdin)["data"][0]["registrationUrl"])')
COMMAND="sudo docker run -e CATTLE_AGENT_IP="${WORKER_IP}" -d --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/rancher:/var/lib/rancher ${WORKER_AGENT} ${URL}"

docker-machine ssh ${WORKER_NAME} ${COMMAND}

echo "I: (${WORKER_NAME}->${WORKER_IP}) creating rancher agent ... "
echo "Done! Rancher is running at http://${SERVER_IP}:8080"
