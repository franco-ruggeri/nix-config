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

_ZFS_ROOT = Path("/mnt")
_RESTIC_REPOSITORIES = {
    "zfs/k8s-nfs": _ZFS_ROOT / "zfs" / "k8s-nfs-backup",
    "zfs/k8s-longhorn": _ZFS_ROOT / "zfs" / "k8s-longhorn-backup",
}
_LONGHORN_STORAGE_CLASS = "longhorn"


def _test_longhorn_backups() -> None:
    result = run_shell_cmd(["kubectl", "get", "pv", "-o", "json"], capture_output=True)
    data = json.loads(result.stdout)
    persistent_volumes: set[str] = set()
    for pv in data.get("items"):
        if pv["spec"]["storageClassName"] != _LONGHORN_STORAGE_CLASS:
            continue
        persistent_volumes.add(pv["metadata"]["name"])
    if not persistent_volumes:
        raise Exception("Longhorn: No Longhorn PVs found.")
    for pv in persistent_volumes:
        logging.info(f"Longhorn: Found PV {pv} using Longhorn storage class.")

    result = run_shell_cmd(
        ["kubectl", "get", "backups.longhorn.io", "-A", "-o", "json"],
        capture_output=True,
    )
    data = json.loads(result.stdout)
    pv_to_dt: dict[str, datetime] = {}
    for backup in data["items"]:
        pv = backup["metadata"]["labels"]["backup-volume"]
        state = backup["status"]["state"]
        if state != "Completed":
            continue
        dt = datetime.strptime(
            backup["status"]["snapshotCreatedAt"],
            "%Y-%m-%dT%H:%M:%SZ",
        )
        if pv in persistent_volumes and (pv not in pv_to_dt or dt > pv_to_dt[pv]):
            pv_to_dt[pv] = dt
    for pv, dt in pv_to_dt.items():
        logging.info(f"Longhorn: Found backup for PV {pv} created at {dt}.")

    if set(pv_to_dt.keys()) != persistent_volumes:
        raise Exception("Longhorn: Some PVs have no backups.")
    if any(datetime.now() - dt > MAX_AGE_HOURS for dt in pv_to_dt.values()):
        raise Exception("Longhorn: Some backups are too old.")
    logging.info("Longhorn: All backups are recent enough.")


def _set_restic_env(repository: Path) -> None:
    os.environ["RESTIC_REPOSITORY"] = str(repository)
    os.environ["RESTIC_CACHE_DIR"] = "/tmp/restic-cache"
    os.environ["RESTIC_PROGRESS_FPS"] = str(1 / 60)  # print progress once per minute

    # Needed to avoid considering all files changed for every new ZFS snapshot.
    # See https://forum.restic.net/t/backing-up-zfs-snapshots-good-idea/9604
    os.environ["RESTIC_FEATURES"] = "device-id-for-hardlinks"


def _make_restic_backup() -> None:
    for zfs_dataset in _RESTIC_REPOSITORIES.keys():
        snapshot = f"{zfs_dataset}@restic"
        run_shell_cmd(["zfs", "snapshot", snapshot])
        logging.info(f"ZFS: Created snapshot {snapshot}.")

    for zfs_dataset, restic_repository in _RESTIC_REPOSITORIES.items():
        _set_restic_env(restic_repository)

        try:
            run_shell_cmd(["restic", "cat", "config"])
        except Exception:
            run_shell_cmd(["restic", "init"])
            logging.info(f"Restic: Initialized restic repository for {zfs_dataset}...")

        logging.info(f"Restic: Backing up {zfs_dataset}...")
        run_shell_cmd(
            cmd=["restic", "backup", "."],
            cwd=_ZFS_ROOT / zfs_dataset / ".zfs" / "snapshot" / "restic",
        )
        logging.info(f"Restic: Backup of {zfs_dataset} completed.")

        logging.info(f"Restic: Pruning old snapshots for {zfs_dataset}...")
        run_shell_cmd(
            [
                "restic",
                "forget",
                "--keep-daily=7",
                "--keep-weekly=4",
                "--keep-monthly=6",
                "--prune",
            ]
        )
        logging.info(f"Restic: Pruned old snapshots for {zfs_dataset}...")

    for zfs_dataset in _RESTIC_REPOSITORIES.keys():
        snapshot = f"{zfs_dataset}@restic"
        run_shell_cmd(["zfs", "destroy", snapshot])
        logging.info(f"ZFS: Destroyed snapshot {snapshot}.")


def _test_restic_snapshots() -> None:
    for zfs_dataset in _RESTIC_REPOSITORIES.keys():
        result = run_shell_cmd(["restic", "snapshots", "--json"], capture_output=True)
        snapshots = json.loads(result.stdout)
        if not snapshots:
            raise Exception(f"Restic: No restic snapshots found for {zfs_dataset}.")

        latest_snapshot = max(snapshots, key=lambda snapshot: snapshot["time"])
        dt_str = latest_snapshot["time"].split(".")[0]
        dt = datetime.strptime(dt_str, "%Y-%m-%dT%H:%M:%S")
        if datetime.now() - dt > MAX_AGE_HOURS:
            raise Exception(f"Restic: Snapshot is too old for {zfs_dataset}.")

        size = latest_snapshot["summary"]["total_bytes_processed"]
        if size == 0:
            raise Exception(f"Restic: Snapshot size is 0 for {zfs_dataset}.")

    logging.info("Restic: Found valid restic snapshots for all ZFS datasets.")


def _test_restic_metadata() -> None:
    for zfs_dataset, restic_repository in _RESTIC_REPOSITORIES.items():
        _set_restic_env(restic_repository)
        run_shell_cmd(["restic", "check"])
        logging.info(f"Restic: Restic metadata for {zfs_dataset} is valid.")


def _test_restic_data() -> None:
    for zfs_dataset, restic_repository in _RESTIC_REPOSITORIES.items():
        _set_restic_env(restic_repository)
        run_shell_cmd(["restic", "check", "--read-data"])
        logging.info(f"Restic: Restic data for {zfs_dataset} is valid.")


def main() -> None:
    errors: list[str] = []
    now = datetime.now()

    run_and_log(run_fn=_make_restic_backup, errors=errors)
    run_and_log(run_fn=_test_restic_snapshots, errors=errors)
    run_and_log(run_fn=_test_longhorn_backups, errors=errors)

    if now.weekday() == 0:
        run_and_log(run_fn=_test_restic_metadata, errors=errors)

    if now.day == 1:
        run_and_log(run_fn=_test_restic_data, errors=errors)

    notify(errors)
