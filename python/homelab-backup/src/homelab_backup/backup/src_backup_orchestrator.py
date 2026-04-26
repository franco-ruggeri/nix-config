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
        if self.dataset_backups:
            self.dataset_backups[0].prune_repository()
            logging.info("Restic: Pruned old snapshots from shared repository.")

    def verify_snapshots(self) -> None:
        for dataset_backup in self.dataset_backups:
            dataset_backup.verify_recent_snapshot(self.max_age)
            dataset_backup.verify_latest_snapshot_nonzero()
        logging.info("Restic: Found valid restic snapshots for all ZFS datasets.")

    def verify_metadata(self) -> None:
        if self.dataset_backups:
            self.dataset_backups[0].check_repository_metadata()
            logging.info("Restic: Restic metadata for shared repository is valid.")

    def verify_data(self) -> None:
        if self.dataset_backups:
            self.dataset_backups[0].check_repository_data()
            logging.info("Restic: Restic data for shared repository is valid.")
