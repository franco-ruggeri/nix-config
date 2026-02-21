#!/bin/bash

set -e

timestamp=$(date +%Y%m%d-%H%M%S)

echo "Creating ZFS snapshots..."
zfs snapshot "zfs/k8s-nfs@$timestamp"
zfs snapshot "zfs/k8s-longhorn@$timestamp"
echo "ZFS snapshots created successfully"
