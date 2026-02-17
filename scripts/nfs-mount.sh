#!/usr/bin/env bash

set -e

EXPORT="k8s-backup"
EXPORT_PATH="$NFS_SERVER_ADDRESS:/$EXPORT"
MOUNT_POINT="$NFS_MOUNT_POINT/$EXPORT"

if mount | grep -q "$NFS_MOUNT_POINT"; then
	echo "NFS export already mounted at $NFS_MOUNT_POINT"
	exit 0
fi

echo "Mounting NFS exports..."
mkdir -p "$MOUNT_POINT"
mount -t nfs -o vers=4.1,resvport "$EXPORT_PATH" "$MOUNT_POINT"
echo "NFS exports mounted successfully"
