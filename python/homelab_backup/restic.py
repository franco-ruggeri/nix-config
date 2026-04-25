import json
import logging
import os
from datetime import datetime
from pathlib import Path

from .utils import (
    MAX_AGE_HOURS,
    notify,
    run_and_log,
    run_shell_cmd,
)


def _get_zfs_mount_root() -> Path:
    zfs_mount_root = os.environ.get("ZFS_MOUNT_ROOT")
    if not zfs_mount_root:
        raise Exception("ZFS_MOUNT_ROOT environment variable not set.")
    return Path(zfs_mount_root)


def _get_zfs_datasets() -> list[str]:
    zfs_datasets_str = os.environ.get("ZFS_DATASETS")
    if not zfs_datasets_str:
        raise Exception("ZFS_DATASETS environment variable not set.")
    return zfs_datasets_str.split(",")


def _get_zfs_snapshot_datetime(name: str) -> datetime:
    parts = name.split("-")
    yyyy, mm, dd = parts[3], parts[4], parts[5]
    hh = parts[6].split("h")[0]
    dt_str = f"{yyyy}-{mm}-{dd} {hh}"
    return datetime.strptime(dt_str, "%Y-%m-%d %H")


def _restic_backup():
    try:
        run_shell_cmd(["restic", "cat", "config"])
    except Exception:
        logging.info("Restic repository not found. Initializing...")
        run_shell_cmd(["restic", "init"])

    zfs_mount_root = _get_zfs_mount_root()
    zfs_datasets = _get_zfs_datasets()
    for zfs_dataset in zfs_datasets:
        zfs_dataset_path = zfs_mount_root / zfs_dataset
        snapshots_root = zfs_dataset_path / ".zfs" / "snapshot"
        snapshots = [d for d in snapshots_root.iterdir() if d.is_dir()]
        if not snapshots:
            raise Exception(f"No snapshots found for {zfs_dataset}.")

        snapshot = max(snapshots, key=lambda d: _get_zfs_snapshot_datetime(d.name))
        logging.info(f"Backing up {snapshot}...")
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
        logging.info(f"Backup of {snapshot} completed.")

    logging.info("Pruning old snapshots...")
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


def _test_zfs_snapshots() -> None:
    zfs_mount_root = _get_zfs_mount_root()
    zfs_datasets = _get_zfs_datasets()
    for zfs_dataset in zfs_datasets:
        path = zfs_mount_root / zfs_dataset / ".zfs" / "snapshot"
        zfs_snapshots = list(path.iterdir())
        if len(zfs_snapshots) == 0:
            raise Exception(f"ZFS: No ZFS snapshots found for {zfs_dataset}.")

        latest_dt = None
        for zfs_snapshot in zfs_snapshots:
            dt_str = "-".join(zfs_snapshot.name.split("-")[3:])
            dt = datetime.strptime(dt_str, "%Y-%m-%d-%Hh%MU")
            latest_dt = max(dt, latest_dt) if latest_dt else dt
        if not latest_dt:
            raise Exception(f"ZFS: No valid ZFS snapshots found for {zfs_dataset}.")

        if datetime.now() - latest_dt > MAX_AGE_HOURS:
            raise Exception(f"ZFS: No recent ZFS snapshots for {zfs_dataset}.")
    logging.info("ZFS: Found recent ZFS snapshots for all ZFS datasets.")


def _test_restic_snapshots() -> None:
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
        dt_str = snapshot["time"].split(".")[0]
        dt = datetime.strptime(dt_str, "%Y-%m-%dT%H:%M:%S")
        if tag not in tag_to_dt or dt > tag_to_dt[tag]:
            tag_to_dt[tag] = dt
            tag_to_size[tag] = snapshot["summary"]["total_bytes_processed"]

    if set(tag_to_dt.keys()) != set(_get_zfs_datasets()):
        raise Exception("Restic: Not all the ZFS datasets have restic snapshots.")
    if any(datetime.now() - dt > MAX_AGE_HOURS for dt in tag_to_dt.values()):
        raise Exception("Restic: Some restic snapshots are too old.")
    if any(size == 0 for size in tag_to_size.values()):
        raise Exception("Restic: Some restic snapshots have size 0.")
    logging.info("Restic: Found valid restic snapshots for all ZFS datasets.")


def _test_restic_metadata() -> None:
    run_shell_cmd(["restic", "check"])
    logging.info("Restic: Restic metadata is valid.")


def _test_restic_data() -> None:
    run_shell_cmd(["restic", "check", "--read-data"])
    logging.info("Restic: Restic data is valid.")


def main() -> None:
    errors: list[str] = []
    now = datetime.now()

    run_and_log(run_fn=_restic_backup, errors=errors)
    run_and_log(run_fn=_test_zfs_snapshots, errors=errors)
    run_and_log(run_fn=_test_restic_snapshots, errors=errors)

    if now.weekday() == 0:
        run_and_log(run_fn=_test_restic_metadata, errors=errors)

    if now.day == 1:
        run_and_log(run_fn=_test_restic_data, errors=errors)

    notify(errors)
