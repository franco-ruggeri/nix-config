#!/usr/bin/env bash

set -e

if ! mount | grep -q "$NFS_MOUNT_POINT"; then
	echo "NFS export not mounted at $NFS_MOUNT_POINT."
	exit 1
fi

if ! restic cat config; then
	echo "Restic repository not found. Initializing..."
	restic init
fi

echo "Preparing backup environment..."
timestamp=$(date +%Y%m%d-%H%M%S)
backup_path="/tmp/k8s-backup-$timestamp"
mkdir -p "$backup_path"
cd "$backup_path" # relative paths for restic

echo "Linking latest snapshots..."
link_latest() {
	local dir="$1"
	local src
	src=$(find "$NFS_MOUNT_POINT/k8s-backup/$dir" -mindepth 1 -maxdepth 1 -type d | sort | tail -n1)
	ln -s "$src" "$dir"
}
link_latest "nfs"
link_latest "longhorn"

echo "Starting restic backup..."
restic backup .

echo "Pruning old snapshots..."
restic forget --keep-daily=7 --keep-weekly=4 --keep-monthly=6
restic prune

echo "Checking backup integrity..."
restic check

echo "Backup completed successfully"
