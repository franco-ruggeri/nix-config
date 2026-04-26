import logging
from datetime import timedelta

from .restic_repository import ResticRepository
from ..datasets.zfs_dataset import ZfsDataset


class DatasetBackup:
    def __init__(self, dataset: ZfsDataset, repository: ResticRepository) -> None:
        self.dataset = dataset
        self.repository = repository

    def run_backup_cycle(self, snapshot_name: str = "restic") -> None:
        self.dataset.create_snapshot(snapshot_name)
        primary_error: Exception | None = None

        try:
            self.repository.ensure_initialized()
            snapshot_path = self.dataset.snapshot_path(snapshot_name)
            logging.info("Restic: Backing up %s...", self.dataset.name)
            self.repository.backup_directory(snapshot_path)
            logging.info("Restic: Backup of %s completed.", self.dataset.name)
            self.repository.forget_prune()
            logging.info("Restic: Pruned old snapshots for %s.", self.dataset.name)
        except Exception as error:
            primary_error = error
            raise
        finally:
            try:
                if self.dataset.snapshot_exists(snapshot_name):
                    self.dataset.destroy_snapshot(snapshot_name)
            except Exception as cleanup_error:
                logging.error(
                    "Failed to cleanup snapshot %s for %s: %s",
                    snapshot_name,
                    self.dataset.name,
                    cleanup_error,
                )
                if primary_error is None:
                    raise

    def verify_recent_snapshot(self, max_age: timedelta) -> None:
        self.repository.verify_recent_snapshot(max_age)

    def verify_latest_snapshot_nonzero(self) -> None:
        self.repository.verify_latest_snapshot_nonzero()

    def check_repository_metadata(self) -> None:
        self.repository.check_metadata()

    def check_repository_data(self) -> None:
        self.repository.check_data()
