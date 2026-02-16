#!/usr/bin/env bash

set -e

if mount | grep -q "$NFS_MOUNT_POINT"; then
	echo "NFS export already mounted at $NFS_MOUNT_POINT"
	exit 0
fi

mount_nfs_export() {
	local export="$1"
	local export_path="$NFS_SERVER_ADDRESS:/$export"
	local mount_point="$NFS_MOUNT_POINT/$export"
	mkdir -p "$mount_point"
	mount -t nfs -o vers=4.1,resvport "$export_path" "$mount_point"
}

echo "Mounting NFS exports..."
mount_nfs_export "/k8s-nfs-ro"
echo "NFS exports mounted successfully"
