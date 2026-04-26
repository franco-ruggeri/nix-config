import logging
from datetime import timedelta

from .dataset_backup import DatasetBackup


class SrcBackupOrchestrator:
    def __init__(self, dataset_backups: list[DatasetBackup], max_age: timedelta) -> None:
        self.dataset_backups = dataset_backups
        self.max_age = max_age

    def run_backup(self) -> None:
        for dataset_backup in self.dataset_backups:
            dataset_backup.run_backup_cycle(snapshot_name="restic")

    def verify_snapshots(self) -> None:
        for dataset_backup in self.dataset_backups:
            dataset_backup.verify_recent_snapshot(self.max_age)
            dataset_backup.verify_latest_snapshot_nonzero()
        logging.info("Restic: Found valid restic snapshots for all ZFS datasets.")

    def verify_metadata(self) -> None:
        for dataset_backup in self.dataset_backups:
            dataset_backup.check_repository_metadata()
            logging.info("Restic: Restic metadata for %s is valid.", dataset_backup.dataset.name)

    def verify_data(self) -> None:
        for dataset_backup in self.dataset_backups:
            dataset_backup.check_repository_data()
            logging.info("Restic: Restic data for %s is valid.", dataset_backup.dataset.name)
