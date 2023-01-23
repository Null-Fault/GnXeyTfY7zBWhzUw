#!/bin/bash

cat << EOF >> /etc/pve/lxc/199.conf 
arch: amd64
cores: 2
features: nesting=1
hostname: docker70
memory: 4096
net0: name=eth0,bridge=vmbr0,firewall=1,gw=192.168.1.1,hwaddr=0E:C3:01:EE:AA:EC,ip=192.168.1.70/24,type=veth
ostype: debian
rootfs: local-lvm:vm-107-disk-0,size=16G
swap: 512
unprivileged: 1
lxc.cgroup.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net dev/net none bind,create=dir
EOF

if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit
fi

PUID=1000
UGID=1111
TZ=

# Wireguard
SERVER_CITIES=
WIREGUARD_PRIVATE_KEY=
WIREGUARD_ADDRESSES=

# slskd
SLSKD_SLSK_USERNAME=
SLSKD_SLSK_PASSWORD=
SLSKD_SLSK_LISTEN_PORT=
# SLSKD_DOWNLOADS_DIR=
# SLSKD_INCOMPLETE_DIR=

# Transmission
TRANSMISSION_PEERPORT=

# Docker location
DOCKER_COMPOSE_FOLDER=~/docker

# Create group on host if it does not exist, name it media
if [ $(cat /etc/group | grep -c ${UGID}) -eq 0 ]; then
    groupadd -g ${UGID} media
fi

# Add current user (root) to media group if not part of it
if [ $(cat /etc/group | grep $(whoami) | grep -c ${UGID}) -eq 0 ]; then
    usermod -a -G media $(whoami)
fi

# Create DOCKER_COMPOSE_FOLDER if it doesn't exist
mkdir -p ${DOCKER_COMPOSE_FOLDER}
touch ${DOCKER_COMPOSE_FOLDER}/docker-compose.yml
mkdir -p ${DOCKER_COMPOSE_FOLDER}/gluetun
mkdir -p ${DOCKER_COMPOSE_FOLDER}/transmission/config
mkdir -p ${DOCKER_COMPOSE_FOLDER}/transmission/downloads
mkdir -p ${DOCKER_COMPOSE_FOLDER}/slskd/app
mkdir -p ${DOCKER_COMPOSE_FOLDER}/slskd/music

# Set permissions for DOCKER_COMPOSE_FOLDER
chown -R ${PUID}:${UGID} ${DOCKER_COMPOSE_FOLDER}
chmod -R a=,a+rX,u+w,g+w ${DOCKER_COMPOSE_FOLDER}

cat << EOF >> ${DOCKER_COMPOSE_FOLDER}/docker-compose.yml
version: "3.0"
services:
  gluetun:
    image: qmcgaw/gluetun
    # sysctls:
    #   - net.ipv6.conf.all.disable_ipv6=0
    #   - net.ipv4.conf.all.src_valid_mark=1
    cap_add:
      - NET_ADMIN
    devices:
       - /dev/net/tun:/dev/net/tun
    environment:
      - VPN_SERVICE_PROVIDER=mullvad
      - VPN_TYPE=wireguard
      - WIREGUARD_PRIVATE_KEY=${WIREGUARD_PRIVATE_KEY}
      - WIREGUARD_ADDRESSES=${WIREGUARD_ADDRESSES}
      - SERVER_CITIES=${SERVER_CITIES}
      - FIREWALL_VPN_INPUT_PORTS=${TRANSMISSION_PEERPORT},${SLSKD_SLSK_LISTEN_PORT}
    volumes:
      - ./gluetun:/gluetun
    ports:
      #- 51820:51820/udp # wireguard
      - ${TRANSMISSION_PEERPORT}:${TRANSMISSION_PEERPORT}/udp # transmission port forward
      - ${TRANSMISSION_PEERPORT}:${TRANSMISSION_PEERPORT} # transmission port forward
      - ${SLSKD_SLSK_LISTEN_PORT}:${SLSKD_SLSK_LISTEN_PORT} # slskd port forward
      - 9091:9091 # transmission
      - 5000:5000 # slskd
    restart: unless-stopped

  transmission:
    image: linuxserver/transmission
    container_name: transmission
    environment:
      - PUID=${PUID}
      - UGID=${UGID}
      - TZ=${TZ}
      - PEERPORT=${TRANSMISSION_PEERPORT}
    volumes:
      - ./transmission/config:/config
      - ./transmission/downloads:/downloads
    network_mode: service:gluetun
    restart: unless-stopped

  slskd:
    image: slskd/slskd
    container_name: slskd
    environment:
      - SLSKD_SLSK_USERNAME=${SLSKD_SLSK_USERNAME}
      - SLSKD_SLSK_PASSWORD=${SLSKD_SLSK_PASSWORD}
      - SLSKD_SLSK_LISTEN_PORT=${SLSKD_SLSK_LISTEN_PORT}
      - SLSKD_SHARED_DIR=/music
      - SLSKD_UPLOAD_SLOTS=10
      - SLSKD_UPLOAD_SPEED_LIMIT=10000
    user: ${PUID}:${UGID}
    volumes:
      - ./slskd/app:/app
      - ./slskd/music:/music
    network_mode: service:gluetun
    restart: unless-stopped
EOF
