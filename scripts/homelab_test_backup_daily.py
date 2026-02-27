#!/usr/bin/env python3

import json
import logging
import os
from datetime import datetime
from pathlib import Path

from homelab_test_backup_utils import MAX_AGE_HOURS, BackupTestError, notify, run, test

ZFS_DATASETS = {"k8s-nfs-ro", "k8s-longhorn-ro"}


def test_nfs_mount() -> None:
    nfs_mount_path = os.environ.get("NFS_MOUNT_PATH")
    for zfs_dataset in ZFS_DATASETS:
        path = Path(nfs_mount_path) / zfs_dataset / ".zfs" / "snapshot"
        zfs_snapshots = list(path.iterdir())
        if len(zfs_snapshots) == 0:
            raise BackupTestError(f"NFS: No ZFS snapshots found for {zfs_dataset}.")

        latest_dt = None
        for zfs_snapshot in zfs_snapshots:
            dt_str = "-".join(zfs_snapshot.name.split("-")[3:])
            dt = datetime.strptime(dt_str, "%Y-%m-%d-%Hh%MU")
            latest_dt = max(dt, latest_dt) if latest_dt else dt
        assert latest_dt is not None

        if datetime.now() - latest_dt > MAX_AGE_HOURS:
            raise BackupTestError(f"NFS: No recent ZFS snapshots for {zfs_dataset}.")
    logging.info("NFS: Found recent ZFS snapshots for all ZFS datasets.")


def test_restic_snapshots() -> None:
    result = run(["restic", "snapshots", "--json"])
    data = json.loads(result.stdout)

    tags = [tag for snapshot in data for tag in snapshot["tags"]]
    if set(tags) != ZFS_DATASETS:
        raise BackupTestError("Restic: Not all the ZFS datasets have restic snapshots.")

    tag_to_dt: dict[str, datetime] = {}
    for snapshot in data:
        for tag in snapshot["tags"]:
            dt = datetime.strptime(snapshot["time"], "%Y-%m-%dT%H:%M:%S.%f%z")
            if tag not in tag_to_dt or dt > tag_to_dt[tag]:
                tag_to_dt[tag] = dt

    if any(datetime.now() - dt > MAX_AGE_HOURS for dt in tag_to_dt.values()):
        raise BackupTestError("Restic: Some restic snapshots are too old.")
    logging.info("Restic: Found recent restic snapshots for all ZFS datasets.")


def main() -> None:
    errors: list[str] = []
    test(test_nfs_mount, errors)
    test(test_restic_snapshots, errors)
    notify(errors)


if __name__ == "__main__":
    main()
