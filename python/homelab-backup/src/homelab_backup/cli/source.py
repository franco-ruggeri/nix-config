import logging
from datetime import datetime
from pathlib import Path

from homelab_backup.backup.restic_repository import ResticRepository
from homelab_backup.backup.zfs_backup import ZfsBackup
from homelab_backup.backup.zfs_dataset import ZfsDataset
from homelab_backup.execution.job_runner import JobRunner
from homelab_backup.execution.local_runner import LocalRunner
from homelab_backup.execution.notifier import Notifier

_ZFS_ROOT = Path("/mnt")
_RESTIC_REPOSITORY = _ZFS_ROOT / "zfs" / "k8s-backup"
_ZFS_DATASETS = [
    "zfs/k8s-nfs",
    "zfs/k8s-longhorn",
]


def main() -> None:
    job = JobRunner()
    now = datetime.now()
    repository = ResticRepository(path=_RESTIC_REPOSITORY)

    local_runner = LocalRunner()
    dataset_backups = [
        ZfsBackup(
            zfs_dataset=ZfsDataset(name=zfs_dataset, runner=local_runner),
            restic_repository=repository,
        )
        for zfs_dataset in _ZFS_DATASETS
    ]

    def run_backup() -> None:
        for dataset_backup in dataset_backups:
            dataset_backup.backup()
        repository.prune()
        logging.info("Restic: Pruned old snapshots from shared repository.")

    def verify_snapshots() -> None:
        for dataset_backup in dataset_backups:
            dataset_backup.verify_snapshot()
        logging.info("Restic: Found valid restic snapshots for all ZFS datasets.")

    def verify_metadata() -> None:
        repository.check_metadata()
        logging.info("Restic: Restic metadata for shared repository is valid.")

    def verify_data() -> None:
        repository.check_data()
        logging.info("Restic: Restic data for shared repository is valid.")

    job.run("backup", run_backup)
    job.run("verify-snapshots", verify_snapshots)

    if now.weekday() == 0:
        job.run("verify-metadata", verify_metadata)

    if now.day == 1:
        job.run("verify-data", verify_data)

    Notifier().notify(job.errors)
