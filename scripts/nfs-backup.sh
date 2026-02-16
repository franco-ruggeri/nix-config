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

echo "Starting restic backup..."
restic backup "$NFS_MOUNT_POINT"

echo "Pruning old snapshots..."
restic forget --keep-daily=7 --keep-weekly=4 --keep-monthly=6
restic prune

echo "Checking backup integrity..."
restic check

echo "Backup completed successfully"
