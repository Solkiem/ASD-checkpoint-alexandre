#!/bin/bash

# shellcheck source=.env
source ../.env

# Variables globales
API_URL="https://node1.infra.wilders.dev:8006/api2/json"
NODE="wcs-cyber-node01"

get_next_vmid() {
    if ! response=$(curl -s -k -H "Authorization: PVEAPIToken=$PROXMOX_TOKEN=$PROXMOX_SECRET" "$API_URL/cluster/nextid"); then
        echo "Error fetching next VMID."
        exit 1
    fi

    # Extract the next available VMID from the API response
    local next_vmid
    next_vmid=$(echo "$response" | jq -r '.data')

    if [ -z "$next_vmid" ]; then
        echo "Failed to fetch the next available VMID."
        exit 1
    fi

    echo "$next_vmid"
}


create_ct() {
    local VMID=$1
    local ISO="local-hdd-templates:vztmpl/debian-12-standard_12_amd64.tar.zst"
    local POOL="ASD-202410"
    local ROOTFS="local-nvme-datas:8"
    local VM_NAME="checkpoint1-alexandre-$VMID"

    echo "Creating CT $VM_NAME with ID $VMID..."
    curl -v -s -k -X POST -H "Authorization: PVEAPIToken=$PROXMOX_TOKEN=$PROXMOX_SECRET" \
    --data-urlencode "vmid=$VMID" \
    --data-urlencode "pool=$POOL" \
    --data-urlencode "ostemplate=$ISO" \
    --data-urlencode "rootfs=$ROOTFS" \
    --data-urlencode "hostname=$VM_NAME" \
    --data-urlencode "password=$CONTAINER_PASSWORD" \
    "$API_URL/nodes/$NODE/lxc"
}

# Main
echo "$PROXMOX_TOKEN"
echo "Starting script execution..."

echo "Fetching the next available VMID"
NEXT_VMID=$(get_next_vmid)

# Pass the VMID to the create_vm function
create_ct "$NEXT_VMID"

# Ensure the file ends with a newline character
printf "\n" >> ../.env

echo "VMID=$NEXT_VMID" >> ../.env

echo "Script execution completed."
