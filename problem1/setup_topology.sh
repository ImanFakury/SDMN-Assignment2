#!/bin/bash

set -e

if [ "$EUID" -ne 0 ]; then
  echo "Run as root"
  exit 1
fi

echo "Creating namespaces"
ip netns add node1
ip netns add node2
ip netns add node3
ip netns add node4
ip netns add router

echo "Creating bridges"
ip link add br1 type bridge
ip link add br2 type bridge
ip link set br1 up
ip link set br2 up

echo "Creating veth pairs"
setup_veth() {
    ip link add "$2" type veth peer name "$3"
    ip link set "$2" netns "$1"
    ip link set "$3" master "$4"
    ip link set "$3" up
}

setup_veth node1 veth-n1 veth-n1-br br1
setup_veth node2 veth-n2 veth-n2-br br1
setup_veth node3 veth-n3 veth-n3-br br2
setup_veth node4 veth-n4 veth-n4-br br2
setup_veth router veth-r1 veth-r1-br br1
setup_veth router veth-r2 veth-r2-br br2

echo "Configuring IPs and routing"
ip netns exec node1 ip link set lo up
ip netns exec node1 ip link set veth-n1 up
ip netns exec node1 ip addr add 172.0.0.2/24 dev veth-n1
ip netns exec node1 ip route add default via 172.0.0.1

ip netns exec node2 ip link set lo up
ip netns exec node2 ip link set veth-n2 up
ip netns exec node2 ip addr add 172.0.0.3/24 dev veth-n2
ip netns exec node2 ip route add default via 172.0.0.1

ip netns exec node3 ip link set lo up
ip netns exec node3 ip link set veth-n3 up
ip netns exec node3 ip addr add 10.10.0.2/24 dev veth-n3
ip netns exec node3 ip route add default via 10.10.0.1

ip netns exec node4 ip link set lo up
ip netns exec node4 ip link set veth-n4 up
ip netns exec node4 ip addr add 10.10.0.3/24 dev veth-n4
ip netns exec node4 ip route add default via 10.10.0.1

ip netns exec router ip link set lo up
ip netns exec router ip link set veth-r1 up
ip netns exec router ip link set veth-r2 up
ip netns exec router ip addr add 172.0.0.1/24 dev veth-r1
ip netns exec router ip addr add 10.10.0.1/24 dev veth-r2

echo "Enabling forwarding"
ip netns exec router sysctl -w net.ipv4.ip_forward=1 > /dev/null

echo "Done"
