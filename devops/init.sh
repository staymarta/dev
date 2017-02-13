# Set eth1 ip to 192.168.99.10
echo "I: changing eth1 ip to ${IP}..."
cat /var/run/udhcpc.eth1.pid | xargs sudo kill
ifconfig eth1 ${IP} netmask 255.255.255.0 broadcast 192.168.99.255 up
ip addr

# Mount persistent data.
echo 'I: making rancher agent data persist...'
mkdir -vp /var/lib/rancher; \
mount -t vboxsf 'agent' /var/lib/rancher
echo "mount returned $?"

# Mount the rancher-agent shared folder.
echo "I: creating persistant '/storage' mount from '${SHARE_PATH}'"
mkdir -vp '/storage'
mount -t nfs -o noacl,noatime,nolock,async "10.0.2.2:${SHARE_PATH}" /storage
echo "mount returned $?"

# Fix rancher/server#7379
echo "I: Fixing rancher/server#7379"
mkdir -p /etc/docker
echo '{ "dns": ["8.8.8.8", "8.8.4.4"], "dns-search": ["example.org"] }' | tee /etc/docker/daemon.json

echo "I: Creating user 'staymarta'"
addgroup -g ${GROUP} staymarta
adduser -u ${ID} -D -s /bin/ash -G staymarta staymarta
