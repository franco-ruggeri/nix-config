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


def _build_dataset_backups(
    repository: ResticRepository,
) -> list[DatasetBackup]:
    local_runner = LocalRunner()
    return [
        DatasetBackup(
            dataset=ZfsDataset(name=zfs_dataset, runner=local_runner),
            repository=repository,
        )
        for zfs_dataset in _ZFS_DATASETS
    ]


def _run_backup(
    dataset_backups: list[DatasetBackup], repository: ResticRepository
) -> None:
    for dataset_backup in dataset_backups:
        dataset_backup.backup(snapshot_name="restic")
    repository.prune()
    logging.info("Restic: Pruned old snapshots from shared repository.")


def _verify_snapshots(dataset_backups: list[DatasetBackup]) -> None:
    for dataset_backup in dataset_backups:
        dataset_backup.verify_snapshot(MAX_AGE_HOURS)
    logging.info("Restic: Found valid restic snapshots for all ZFS datasets.")


def _verify_metadata(repository: ResticRepository) -> None:
    repository.check_metadata()
    logging.info("Restic: Restic metadata for shared repository is valid.")


def _verify_data(repository: ResticRepository) -> None:
    repository.check_data()
    logging.info("Restic: Restic data for shared repository is valid.")


def main() -> None:
    job = JobRunner()
    now = datetime.now()
    repository = ResticRepository(path=_RESTIC_REPOSITORY)
    dataset_backups = _build_dataset_backups(repository)

    job.run("backup", lambda: _run_backup(dataset_backups, repository))
    job.run("verify-snapshots", lambda: _verify_snapshots(dataset_backups))

    if now.weekday() == 0:
        job.run("verify-metadata", lambda: _verify_metadata(repository))

    if now.day == 1:
        job.run("verify-data", lambda: _verify_data(repository))

    Notifier().notify(job.errors)
