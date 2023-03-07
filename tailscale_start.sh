#!/bin/sh

mkdir -p /tmp/tailscale
/usr/sbin/tailscaled --tun=userspace-networking &
until /usr/bin/tailscale up --authkey=${TAILSCALE_AUTHKEY} --hostname=railway-app --advertise-exit-node
do
    sleep 0.1
done
sleep infinity