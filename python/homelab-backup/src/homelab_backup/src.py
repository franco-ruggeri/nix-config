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

_ZFS_MOUNT_ROOT = Path("/mnt/zfs")
_RESTIC_REPOSITORIES = {
    "k8s-nfs": "k8s-nfs-backup",
    "k8s-longhorn": "k8s-longhorn-backup",
}
_ZFS_DATASETS = list(_RESTIC_REPOSITORIES.keys())
_LONGHORN_STORAGE_CLASS = "longhorn"


def _init_env() -> None:
    os.environ["RESTIC_CACHE_DIR"] = "/tmp/restic-cache"
    os.environ["RESTIC_PROGRESS_FPS"] = str(1 / 60)  # print progress once per minute

    # Needed to avoid considering all files changed for every new ZFS snapshot.
    # See https://forum.restic.net/t/backing-up-zfs-snapshots-good-idea/9604
    os.environ["RESTIC_FEATURES"] = "device-id-for-hardlinks"


def _restic_repository_path(dataset: str) -> str:
    return str(_ZFS_MOUNT_ROOT / _RESTIC_REPOSITORIES[dataset])


def _restic_cmd(dataset: str, args: list[str]) -> list[str]:
    return ["restic", "--repo", _restic_repository_path(dataset)] + args


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


def _zfs_snapshot_exists(snapshot_name: str) -> bool:
    result = run_shell_cmd(
        [
            "zfs",
            "list",
            "-H",
            "-t",
            "snapshot",
            "-o",
            "name",
            snapshot_name,
        ],
        capture_output=True,
        raise_on_error=False,
    )
    return result.returncode == 0


def _create_zfs_snapshots() -> dict[str, Path]:
    snapshot_name = "restic"
    dataset_to_snapshot_path: dict[str, Path] = {}

    for zfs_dataset in _ZFS_DATASETS:
        zfs_snapshot = f"zfs/{zfs_dataset}@{snapshot_name}"
        if _zfs_snapshot_exists(zfs_snapshot):
            logging.info(f"ZFS: Destroying existing snapshot {zfs_snapshot}.")
            run_shell_cmd(["zfs", "destroy", zfs_snapshot])

        run_shell_cmd(["zfs", "snapshot", zfs_snapshot])

        snapshot_path = (
            _ZFS_MOUNT_ROOT / zfs_dataset / ".zfs" / "snapshot" / snapshot_name
        )
        if not snapshot_path.exists() or not snapshot_path.is_dir():
            raise Exception(f"ZFS: Snapshot path not found: {snapshot_path}.")

        dataset_to_snapshot_path[zfs_dataset] = snapshot_path
        logging.info(f"ZFS: Created snapshot {zfs_snapshot}.")

    return dataset_to_snapshot_path


def _restic_backup() -> None:
    dataset_to_snapshot_path = _create_zfs_snapshots()

    for zfs_dataset in _ZFS_DATASETS:
        try:
            run_shell_cmd(_restic_cmd(zfs_dataset, ["cat", "config"]), capture_output=True)
        except Exception:
            logging.info(f"Initializing restic repository for {zfs_dataset}...")
            run_shell_cmd(_restic_cmd(zfs_dataset, ["init"]))

        snapshot = dataset_to_snapshot_path[zfs_dataset]
        logging.info(f"Restic: Backing up {snapshot}...")
        run_shell_cmd(
            cmd=[
                *_restic_cmd(zfs_dataset, ["backup"]),
                ".",
            ],
            cwd=snapshot,
        )
        logging.info(f"Restic: Backup of {snapshot} completed.")

        logging.info("Restic: Pruning old snapshots for %s...", zfs_dataset)
        run_shell_cmd(
            _restic_cmd(
                zfs_dataset,
                [
                    "forget",
                    "--keep-daily=7",
                    "--keep-weekly=4",
                    "--keep-monthly=6",
                ],
            ),
        )
        run_shell_cmd(_restic_cmd(zfs_dataset, ["prune"]))


def _test_restic_snapshots() -> None:
    for zfs_dataset in _ZFS_DATASETS:
        result = run_shell_cmd(
            _restic_cmd(zfs_dataset, ["snapshots", "--json"]),
            capture_output=True,
        )
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
    for zfs_dataset in _ZFS_DATASETS:
        run_shell_cmd(_restic_cmd(zfs_dataset, ["check"]))
    logging.info("Restic: Restic metadata is valid.")


def _test_restic_data() -> None:
    for zfs_dataset in _ZFS_DATASETS:
        run_shell_cmd(_restic_cmd(zfs_dataset, ["check", "--read-data"]))
    logging.info("Restic: Restic data is valid.")


def main() -> None:
    errors: list[str] = []
    now = datetime.now()

    _init_env()

    run_and_log(run_fn=_test_longhorn_backups, errors=errors)
    run_and_log(run_fn=_restic_backup, errors=errors)
    run_and_log(run_fn=_test_restic_snapshots, errors=errors)

    if now.weekday() == 0:
        run_and_log(run_fn=_test_restic_metadata, errors=errors)

    if now.day == 1:
        run_and_log(run_fn=_test_restic_data, errors=errors)

    notify(errors)
