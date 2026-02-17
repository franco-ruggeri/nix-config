#!/bin/bash

set -e

TIMESTAMP=$(date +%Y%m%d-%H%M%S)

echo "Creating ZFS snapshots..."
zfs snapshot "zfs/k8s-nfs@$TIMESTAMP"
zfs snapshot "zfs/k8s-longhorn@$TIMESTAMP"
echo "ZFS snapshots created successfully"
