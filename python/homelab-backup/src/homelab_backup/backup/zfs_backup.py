import logging

from homelab_backup.backup.restic_repository import ResticRepository
from homelab_backup.backup.zfs_dataset import ZfsDataset


class ZfsBackup:
    _SNAPSHOT_NAME = "restic"

    def __init__(self, zfs_dataset: ZfsDataset, restic_repository: ResticRepository) -> None:
        self._zfs_dataset = zfs_dataset
        self._restic_repository = restic_repository

    def create_snapshot(self) -> None:
        self._zfs_dataset.create_snapshot(self._SNAPSHOT_NAME)

    def backup_snapshot(self) -> None:
        snapshot_name = self._SNAPSHOT_NAME
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

    def verify_snapshot(self) -> None:
        snapshot_path = self._zfs_dataset.snapshot_path(self._SNAPSHOT_NAME)
        self._restic_repository.verify_snapshot(snapshot_path)
