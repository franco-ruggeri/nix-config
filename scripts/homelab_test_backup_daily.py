#!/usr/bin/env python3

import json
import logging
import os
from datetime import datetime, timezone
from pathlib import Path

from homelab_test_backup_utils import MAX_AGE_HOURS, notify, run, test

ZFS_DATASETS = {"k8s-nfs", "k8s-longhorn"}


def test_nfs_mount() -> None:
    nfs_mount_path = os.environ.get("NFS_MOUNT_PATH")
    assert nfs_mount_path is not None
    for zfs_dataset in ZFS_DATASETS:
        path = Path(nfs_mount_path) / zfs_dataset / ".zfs" / "snapshot"
        zfs_snapshots = list(path.iterdir())
        if len(zfs_snapshots) == 0:
            raise Exception(f"NFS: No ZFS snapshots found for {zfs_dataset}.")

        latest_dt = None
        for zfs_snapshot in zfs_snapshots:
            dt_str = "-".join(zfs_snapshot.name.split("-")[3:])
            dt = datetime.strptime(dt_str, "%Y-%m-%d-%Hh%MU")
            latest_dt = max(dt, latest_dt) if latest_dt else dt
        assert latest_dt is not None

        if datetime.now() - latest_dt > MAX_AGE_HOURS:
            raise Exception(f"NFS: No recent ZFS snapshots for {zfs_dataset}.")
    logging.info("NFS: Found recent ZFS snapshots for all ZFS datasets.")


def test_restic_snapshots() -> None:
    result = run(["restic", "snapshots", "--json"])
    data = json.loads(result.stdout)
    if not data:
        raise Exception("Restic: No restic snapshots found.")

    tag_to_size: dict[str, float] = {}
    tag_to_dt: dict[str, datetime] = {}
    for snapshot in data:
        tags = snapshot["tags"]
        if len(tags) != 1:
            raise Exception("Restic: Each restic snapshot should have exactly one tag.")
        tag = tags[0]
        dt = datetime.strptime(snapshot["time"], "%Y-%m-%dT%H:%M:%S.%f%z")
        if tag not in tag_to_dt or dt > tag_to_dt[tag]:
            tag_to_dt[tag] = dt
            tag_to_size[tag] = snapshot["summary"]["total_bytes_processed"]

    if set(tag_to_dt.keys()) != ZFS_DATASETS:
        raise Exception("Restic: Not all the ZFS datasets have restic snapshots.")
    now = datetime.now(timezone.utc)
    if any(now - dt > MAX_AGE_HOURS for dt in tag_to_dt.values()):
        raise Exception("Restic: Some restic snapshots are too old.")
    if any(size == 0 for size in tag_to_size.values()):
        raise Exception("Restic: Some restic snapshots have size 0.")
    logging.info("Restic: Found valid restic snapshots for all ZFS datasets.")


def main() -> None:
    errors: list[str] = []
    test(test_fn=test_nfs_mount, errors=errors)
    test(test_fn=test_restic_snapshots, errors=errors)
    notify(errors)


if __name__ == "__main__":
    main()
