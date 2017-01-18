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
