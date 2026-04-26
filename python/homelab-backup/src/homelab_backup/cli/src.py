import logging
from datetime import datetime
from pathlib import Path

from homelab_backup.backup.dataset_backup import DatasetBackup
from homelab_backup.backup.restic_repository import ResticRepository
from homelab_backup.datasets.zfs_dataset import ZfsDataset
from homelab_backup.execution.job_runner import JobRunner
from homelab_backup.execution.local_runner import LocalRunner
from homelab_backup.execution.notifier import Notifier
from homelab_backup.utils import MAX_AGE_HOURS

_ZFS_ROOT = Path("/mnt")
_RESTIC_REPOSITORY = _ZFS_ROOT / "zfs" / "k8s-backup"
_ZFS_DATASETS = [
    "zfs/k8s-nfs",
    "zfs/k8s-longhorn",
]


def _build_dataset_backups() -> list[DatasetBackup]:
    local_runner = LocalRunner()
    repository = ResticRepository(path=_RESTIC_REPOSITORY)
    return [
        DatasetBackup(
            dataset=ZfsDataset(name=zfs_dataset, runner=local_runner),
            repository=repository,
        )
        for zfs_dataset in _ZFS_DATASETS
    ]


def _run_backup(dataset_backups: list[DatasetBackup]) -> None:
    for dataset_backup in dataset_backups:
        dataset_backup.run_backup_cycle(snapshot_name="restic")
    if dataset_backups:
        dataset_backups[0].prune_repository()
        logging.info("Restic: Pruned old snapshots from shared repository.")


def _verify_snapshots(dataset_backups: list[DatasetBackup]) -> None:
    for dataset_backup in dataset_backups:
        dataset_backup.verify_snapshot(MAX_AGE_HOURS)
    logging.info("Restic: Found valid restic snapshots for all ZFS datasets.")


def _verify_metadata(dataset_backups: list[DatasetBackup]) -> None:
    if dataset_backups:
        dataset_backups[0].check_repository_metadata()
        logging.info("Restic: Restic metadata for shared repository is valid.")


def _verify_data(dataset_backups: list[DatasetBackup]) -> None:
    if dataset_backups:
        dataset_backups[0].check_repository_data()
        logging.info("Restic: Restic data for shared repository is valid.")


def main() -> None:
    job = JobRunner()
    now = datetime.now()
    dataset_backups = _build_dataset_backups()

    job.run("backup", lambda: _run_backup(dataset_backups))
    job.run("verify-snapshots", lambda: _verify_snapshots(dataset_backups))

    if now.weekday() == 0:
        job.run("verify-metadata", lambda: _verify_metadata(dataset_backups))

    if now.day == 1:
        job.run("verify-data", lambda: _verify_data(dataset_backups))

    Notifier().notify(job.errors)
