#!/usr/bin/env bash

set -e

ZFS_DATASETS=(
	"$NFS_MOUNT_PATH/k8s-nfs-ro"
	"$NFS_MOUNT_PATH/k8s-longhorn-ro"
)

if ! restic cat config; then
	echo "Restic repository not found. Initializing..."
	restic init
fi

for zfs_dataset_path in "${ZFS_DATASETS[@]}"; do
	zfs_dataset=$(basename "$zfs_dataset_path")
	zfs_snapshot=$(find "$zfs_dataset_path/.zfs/snapshot" -mindepth 1 -maxdepth 1 -type d | sort | tail -n1)

	echo "Backing up $zfs_snapshot..."
	cd "$zfs_snapshot" # to have relative paths in the backup

	# --group-by=tags ensures the correct parent snapshot is selected, which is
	# necessary for file change detection. Otherwise, the default
	# --group-by=host,path would not work, as the path changes at every backup.
	# In fact, the source path for the backup is the snapshot directory.
	restic backup --tag="$zfs_dataset" --group-by=tags .

	echo "Backup of $zfs_snapshot completed."
done

echo "Pruning old snapshots..."
restic forget --keep-daily=7 --keep-weekly=4 --keep-monthly=6
restic prune

# TODO: this should be part of the tests (?)
echo "Checking backup integrity..."
restic check
