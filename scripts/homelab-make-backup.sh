#!/usr/bin/env bash

set -e

ZFS_DATASETS=(
	"k8s-nfs"
	"k8s-longhorn"
)

if ! restic cat config; then
	echo "Restic repository not found. Initializing..."
	restic init
fi

for zfs_dataset in "${ZFS_DATASETS[@]}"; do
	zfs_dataset_path="$NFS_MOUNT_PATH/$zfs_dataset"
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
restic forget --group-by=tags --keep-daily=7 --keep-weekly=4 --keep-monthly=6
restic prune
