#!/bin/bash

set -e

TIMESTAMP=$(date +%Y%m%d-%H%M%S)

echo "Creating ZFS snapshots..."
zfs snapshot "zfs/k8s-nfs@backup-$TIMESTAMP"
zfs snapshot "zfs/k8s-longhorn@backup-$TIMESTAMP"
echo "ZFS snapshots created successfully"
