#!/usr/bin/env bash

set -e

# TODO: remove
whoami
groups

is_mounted() {
	local mount_point="$1"
	mount | grep -qs "$mount_point"
}

mount_export() {
	local dir="$1"
	local src="$NFS_SERVER_ADDRESS:/$dir"
	local dest="$NFS_MOUNT_POINT/$dir"
	if is_mounted "$dest"; then
		echo "$dest is already mounted. Skipping."
	else
		echo "Mounting $src to $dest..."
		mkdir -p "$dest"
		mount -t nfs -o vers=4.1,resvport "$src" "$dest"
		echo "Mounted $src to $dest successfully."
	fi
}

get_subdirs() {
	local dir="$1"
	find "$NFS_MOUNT_POINT/$dir" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;
}

echo "Mounting NFS exports..."
# mount_export ""
# mount_export "k8s-backup"
for export_path in "k8s-backup/nfs" "k8s-backup/longhorn"; do
	mount_export "$export_path"

	# TODO: remove
	ls "$NFS_MOUNT_POINT/$export_path"
	subdirs=$(get_subdirs "$export_path")
	echo "Subdirectories in $export_path: $subdirs"

	for snapshot_dir in $(get_subdirs $export_path); do
		mount_export "$export_path/$snapshot_dir"
	done
done
echo "NFS exports mounted successfully"
