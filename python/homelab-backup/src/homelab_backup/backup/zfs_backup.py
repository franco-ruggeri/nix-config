import logging
from datetime import timedelta

from homelab_backup.backup.restic_repository import ResticRepository
from homelab_backup.backup.zfs_dataset import ZfsDataset


class ZfsBackup:
    def __init__(self, zfs_dataset: ZfsDataset, restic_repository: ResticRepository) -> None:
        self._zfs_dataset = zfs_dataset
        self._restic_repository = restic_repository

    def backup(self, snapshot_name: str = "restic") -> None:
        self._zfs_dataset.create_snapshot(snapshot_name)
        primary_error: Exception | None = None
        try:
            self._restic_repository.ensure_initialized()
            snapshot_path = self._zfs_dataset.snapshot_path(snapshot_name)
            logging.info("Restic: Backing up %s...", self._zfs_dataset.name)
            self._restic_repository.backup(snapshot_path)
            logging.info("Restic: Backup of %s completed.", self._zfs_dataset.name)
        except Exception as error:
            primary_error = error
            raise
        finally:
            try:
                if self._zfs_dataset.snapshot_exists(snapshot_name):
                    self._zfs_dataset.destroy_snapshot(snapshot_name)
            except Exception as cleanup_error:
                logging.error(
                    "Failed to cleanup snapshot %s for %s: %s",
                    snapshot_name,
                    self._zfs_dataset.name,
                    cleanup_error,
                )
                if primary_error is None:
                    raise

    def verify_snapshot(self, max_age: timedelta) -> None:
        snapshot_path = self._zfs_dataset.snapshot_path("restic")
        self._restic_repository.verify_snapshot(max_age, snapshot_path)
