import logging
from datetime import timedelta

from homelab_backup.backup.restic_repository import ResticRepository
from homelab_backup.backup.zfs_dataset import ZfsDataset


class ZfsBackup:
    def __init__(self, dataset: ZfsDataset, repository: ResticRepository) -> None:
        self._dataset = dataset
        self._repository = repository

    def backup(self, snapshot_name: str = "restic") -> None:
        self._dataset.create_snapshot(snapshot_name)
        primary_error: Exception | None = None
        try:
            self._repository.ensure_initialized()
            snapshot_path = self._dataset.snapshot_path(snapshot_name)
            logging.info("Restic: Backing up %s...", self._dataset.name)
            self._repository.backup(snapshot_path)
            logging.info("Restic: Backup of %s completed.", self._dataset.name)
        except Exception as error:
            primary_error = error
            raise
        finally:
            try:
                if self._dataset.snapshot_exists(snapshot_name):
                    self._dataset.destroy_snapshot(snapshot_name)
            except Exception as cleanup_error:
                logging.error(
                    "Failed to cleanup snapshot %s for %s: %s",
                    snapshot_name,
                    self._dataset.name,
                    cleanup_error,
                )
                if primary_error is None:
                    raise

    def verify_snapshot(self, max_age: timedelta) -> None:
        snapshot_path = self._dataset.snapshot_path("restic")
        self._repository.verify_snapshot(max_age, snapshot_path)
