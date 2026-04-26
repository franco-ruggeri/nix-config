import logging
from datetime import datetime
from pathlib import Path

from homelab_backup.backup.restic_repository import ResticRepository
from homelab_backup.backup.zfs_backup import ZfsBackup
from homelab_backup.backup.zfs_dataset import ZfsDataset
from homelab_backup.execution.local_runner import LocalRunner
from homelab_backup.execution.notifier import Notifier

_RESTIC_REPOSITORY = Path("/mnt") / "zfs" / "k8s-backup"
_ZFS_DATASETS = ["zfs/k8s-nfs", "zfs/k8s-longhorn"]


def main() -> None:
    try:
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

        for dataset_backup in dataset_backups:
            dataset_backup.create_snapshot()
        for dataset_backup in dataset_backups:
            dataset_backup.backup_snapshot()
        repository.prune()
        logging.info("Restic: Pruned old snapshots from shared repository.")

        for dataset_backup in dataset_backups:
            dataset_backup.verify_snapshot()
        logging.info("Restic: Found valid restic snapshots for all ZFS datasets.")

        if now.weekday() == 0:
            repository.check_metadata()
            logging.info("Restic: Restic metadata for shared repository is valid.")

        if now.day == 1:
            repository.check_data()
            logging.info("Restic: Restic data for shared repository is valid.")

        Notifier().notify(None)
    except Exception as e:
        logging.error("%s", e)
        Notifier().notify(e)
