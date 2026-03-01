#!/usr/bin/env python3

import json
import logging
import os
from datetime import datetime
from pathlib import Path

from homelab_backup_utils import (
    MAX_AGE_HOURS,
    ZFS_DATASETS,
    notify,
    run_and_log,
    run_shell_cmd,
)


def get_nfs_mount_path() -> Path:
    nfs_mount_path = os.environ.get("NFS_MOUNT_PATH")
    if not nfs_mount_path:
        raise Exception("NFS_MOUNT_PATH environment variable not set.")
    return Path(nfs_mount_path)


def restic_backup():
    try:
        run_shell_cmd(["restic", "cat", "config"])
    except Exception:
        print("Restic repository not found. Initializing...")
        run_shell_cmd(["restic", "init"])

    nfs_mount_path = get_nfs_mount_path()
    for zfs_dataset in ZFS_DATASETS:
        zfs_dataset_path = nfs_mount_path / zfs_dataset
        snapshots_root = zfs_dataset_path / ".zfs" / "snapshot"
        snapshots = [d for d in snapshots_root.iterdir() if d.is_dir()]
        if not snapshots:
            raise Exception(f"No snapshots found for {zfs_dataset}.")

        snapshots.sort()
        snapshot = snapshots[-1]
        logging.info(f"Backing up {snapshot}...")
        try:
            run_shell_cmd(
                cmd=[
                    "restic",
                    "backup",
                    f"--tag={zfs_dataset}",
                    "--group-by=tags",
                    ".",
                ],
                cwd=snapshot,
            )
        except Exception as e:
            print(f"Error during backup of {snapshot}: {e}", file=sys.stderr)
            continue
        print(f"Backup of {snapshot} completed.")

    print("Pruning old snapshots...")
    run_shell_cmd(
        [
            "restic",
            "forget",
            "--group-by=tags",
            "--keep-daily=7",
            "--keep-weekly=4",
            "--keep-monthly=6",
        ]
    )
    run_shell_cmd(["restic", "prune"])


def test_nfs_mount() -> None:
    nfs_mount_path = get_nfs_mount_path()
    for zfs_dataset in ZFS_DATASETS:
        path = nfs_mount_path / zfs_dataset / ".zfs" / "snapshot"
        zfs_snapshots = list(path.iterdir())
        if len(zfs_snapshots) == 0:
            raise Exception(f"NFS: No ZFS snapshots found for {zfs_dataset}.")

        latest_dt = None
        for zfs_snapshot in zfs_snapshots:
            dt_str = "-".join(zfs_snapshot.name.split("-")[3:])
            dt = datetime.strptime(dt_str, "%Y-%m-%d-%Hh%MU")
            latest_dt = max(dt, latest_dt) if latest_dt else dt
        if not latest_dt:
            raise Exception(f"NFS: No valid ZFS snapshots found for {zfs_dataset}.")

        if datetime.now() - latest_dt > MAX_AGE_HOURS:
            raise Exception(f"NFS: No recent ZFS snapshots for {zfs_dataset}.")
    logging.info("NFS: Found recent ZFS snapshots for all ZFS datasets.")


def test_restic_snapshots() -> None:
    result = run_shell_cmd(["restic", "snapshots", "--json"])
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
        dt_str = snapshot["time"].split(".")[0]  # up to seconds
        dt = datetime.strptime(dt_str, "%Y-%m-%dT%H:%M:%S")
        if tag not in tag_to_dt or dt > tag_to_dt[tag]:
            tag_to_dt[tag] = dt
            tag_to_size[tag] = snapshot["summary"]["total_bytes_processed"]

    if set(tag_to_dt.keys()) != ZFS_DATASETS:
        raise Exception("Restic: Not all the ZFS datasets have restic snapshots.")
    if any(datetime.now() - dt > MAX_AGE_HOURS for dt in tag_to_dt.values()):
        raise Exception("Restic: Some restic snapshots are too old.")
    if any(size == 0 for size in tag_to_size.values()):
        raise Exception("Restic: Some restic snapshots have size 0.")
    logging.info("Restic: Found valid restic snapshots for all ZFS datasets.")


def test_restic_metadata() -> None:
    run_shell_cmd(["restic", "check"])
    logging.info("Restic: Restic metadata is valid.")


def test_restic_data() -> None:
    run_shell_cmd(["restic", "check", "--read-data"])
    logging.info("Restic: Restic data is valid.")


def main() -> None:
    errors: list[str] = []
    now = datetime.now()

    # Backup
    run_and_log(run_fn=restic_backup, errors=errors)

    # Daily tests
    run_and_log(run_fn=test_nfs_mount, errors=errors)
    run_and_log(run_fn=test_restic_snapshots, errors=errors)

    # Weekly tests
    if now.weekday() == 0:
        run_and_log(run_fn=test_restic_metadata, errors=errors)

    # Monthly tests
    if now.day == 1:
        run_and_log(run_fn=test_restic_data, errors=errors)

    # Notify results
    notify(errors)


if __name__ == "__main__":
    main()
