import json
import logging
from datetime import datetime
from pathlib import Path

from .dataset_backup import DatasetBackup
from .local_runner import LocalRunner
from .restic_repository import ResticRepository
from .zfs_dataset import ZfsDataset
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


def _build_dataset_backups() -> list[DatasetBackup]:
    local_runner = LocalRunner()
    return [
        DatasetBackup(
            dataset=ZfsDataset(name=zfs_dataset, runner=local_runner),
            repository=ResticRepository(path=restic_repository),
        )
        for zfs_dataset, restic_repository in _RESTIC_REPOSITORIES.items()
    ]


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


def _make_restic_backup() -> None:
    for dataset_backup in _build_dataset_backups():
        dataset_backup.run_backup_cycle(snapshot_name="restic")


def _test_restic_snapshots() -> None:
    for dataset_backup in _build_dataset_backups():
        dataset_backup.verify_recent_snapshot(MAX_AGE_HOURS)
        dataset_backup.verify_latest_snapshot_nonzero()

    logging.info("Restic: Found valid restic snapshots for all ZFS datasets.")


def _test_restic_metadata() -> None:
    for dataset_backup in _build_dataset_backups():
        dataset_backup.check_repository_metadata()
        logging.info("Restic: Restic metadata for %s is valid.", dataset_backup.dataset.name)


def _test_restic_data() -> None:
    for dataset_backup in _build_dataset_backups():
        dataset_backup.check_repository_data()
        logging.info("Restic: Restic data for %s is valid.", dataset_backup.dataset.name)


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
