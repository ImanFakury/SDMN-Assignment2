#!/bin/bash

NODE_FROM=$1
NODE_TO=$2

if [ -z "$NODE_FROM" ] || [ -z "$NODE_TO" ]; then
    echo "Missing arguments"
    exit 1
fi

declare -A IPs=(
    ["node1"]="172.0.0.2"
    ["node2"]="172.0.0.3"
    ["node3"]="10.10.0.2"
    ["node4"]="10.10.0.3"
    ["router"]="172.0.0.1"
)

TARGET_IP=${IPs[$NODE_TO]}

if [ -z "$TARGET_IP" ]; then
    echo "Unknown target"
    exit 1
fi

echo "Pinging $NODE_TO from $NODE_FROM"
ip netns exec "$NODE_FROM" ping "$TARGET_IP"
