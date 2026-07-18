#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "Run as root"
  exit 1
fi

HOSTNAME=$1
MEM_MB=$2

if [ -z "$HOSTNAME" ]; then
    echo "Usage: $0 <hostname> [memory_limit_mb]"
    exit 1
fi

BASE_ROOTFS="/var/lib/mycontainer/ubuntu20.04"
CONT_ROOTFS="/var/lib/mycontainer/instances/$HOSTNAME"

if [ ! -d "$BASE_ROOTFS" ]; then
    echo "Base rootfs missing"
    exit 1
fi

if [ ! -d "$CONT_ROOTFS" ]; then
    echo "Creating filesystem"
    mkdir -p "/var/lib/mycontainer/instances"
    cp -a "$BASE_ROOTFS" "$CONT_ROOTFS"
else
    echo "Filesystem exists"
fi

if [ -n "$MEM_MB" ]; then
    echo "Applying memory limit: ${MEM_MB}MB"
    if [ -d "/sys/fs/cgroup" ] && [ -f "/sys/fs/cgroup/cgroup.controllers" ]; then
        CG_PATH="/sys/fs/cgroup/container_$HOSTNAME"
        mkdir -p "$CG_PATH"
        echo "$((MEM_MB * 1024 * 1024))" > "$CG_PATH/memory.max"
        echo "$$" > "$CG_PATH/cgroup.procs"
    elif [ -d "/sys/fs/cgroup/memory" ]; then
        CG_PATH="/sys/fs/cgroup/memory/container_$HOSTNAME"
        mkdir -p "$CG_PATH"
        echo "$((MEM_MB * 1024 * 1024))" > "$CG_PATH/memory.limit_in_bytes"
        echo "$$" > "$CG_PATH/tasks"
    else
        echo "Cgroup not detected, skipping memory limit"
    fi
fi

echo "Starting container: $HOSTNAME"
unshare -u -n -p -m -f -R "$CONT_ROOTFS" --mount-proc /bin/bash -c "hostname $HOSTNAME; exec /bin/bash"
