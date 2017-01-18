#!/usr/bin/env bash
#
# (c) 2017 StayMarta
#
# Init script for worker boot2docker machines.

# Set eth1 ip to 192.168.99.10
echo 'I: changing eth1 ip ...'
cat /var/run/udhcpc.eth1.pid | xargs sudo kill
ifconfig eth1 192.168.99.10 netmask 255.255.255.0 broadcast 192.168.99.255 up
ip addr

# Mount persistent data.
echo 'I: making rancher agent data persist...'
mkdir -vp /var/lib/rancher; \
mount -t vboxsf 'agent' /var/lib/rancher
echo "mount returned $?"

# Mount the rancher-agent shared folder.
echo 'I: creating persistant /storage mount...'
mkdir -vp '/storage'
mount -t vboxsf -o uid=1000,gid=50 'storage' /storage
echo "mount returned $?"
