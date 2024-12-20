#!/bin/bash

source ../.env

API_URL="https://node1.infra.wilders.dev:8006/api2/json"
NODE="wcs-cyber-node01"

add_networks() {
    curl -v -s -k -X PUT -H "Authorization: PVEAPIToken=$PROXMOX_TOKEN=$PROXMOX_SECRET" \
    --data-urlencode "net0=name=CTNetwork,bridge=vmbr3,firewall=1,gw6=2a01:4f8:141:53ea::2,ip6=2a01:4f8:141:53ea::$VMID/64" \
    "$API_URL/nodes/$NODE/lxc/$VMID/config"
}

echo "add networks to the container ..."
add_networks