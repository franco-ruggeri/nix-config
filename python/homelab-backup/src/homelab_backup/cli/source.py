import logging
from datetime import datetime
from pathlib import Path

from homelab_backup.core.restic_repository import ResticRepository
from homelab_backup.core.zfs_dataset import ZfsDataset
from homelab_backup.notifiers.email_notifier import EmailNotifier
from homelab_backup.runners.local_runner import LocalRunner

_RESTIC_REPOSITORY = Path("/mnt") / "zfs" / "k8s-backup"
_ZFS_DATASETS = ["zfs/k8s-nfs", "zfs/k8s-longhorn"]
_SNAPSHOT_NAME = "restic"


def _backup_dataset(dataset: ZfsDataset, repository: ResticRepository) -> None:
    snapshot_name = _SNAPSHOT_NAME
    primary_error: Exception | None = None
    try:
        repository.ensure_initialized()
        snapshot_path = dataset.snapshot_path(snapshot_name)
        logging.info("Restic: Backing up %s...", dataset.name)
        repository.backup(snapshot_path)
        logging.info("Restic: Backup of %s completed.", dataset.name)
    except Exception as error:
        primary_error = error
        raise
    finally:
        try:
            if dataset.snapshot_exists(snapshot_name):
                dataset.destroy_snapshot(snapshot_name)
        except Exception as cleanup_error:
            logging.error(
                "Failed to cleanup snapshot %s for %s: %s",
                snapshot_name,
                dataset.name,
                cleanup_error,
            )
            if primary_error is None:
                raise


def main() -> None:
    try:
        now = datetime.now()
        repository = ResticRepository(path=_RESTIC_REPOSITORY)

        local_runner = LocalRunner()
        datasets = [ZfsDataset(name=zfs_dataset, runner=local_runner) for zfs_dataset in _ZFS_DATASETS]

        for dataset in datasets:
            dataset.create_snapshot(_SNAPSHOT_NAME)
        for dataset in datasets:
            _backup_dataset(dataset, repository)
        repository.prune()
        logging.info("Restic: Pruned old snapshots from shared repository.")

        for dataset in datasets:
            repository.verify_snapshot(dataset.snapshot_path(_SNAPSHOT_NAME))
        logging.info("Restic: Found valid restic snapshots for all ZFS datasets.")

        if now.weekday() == 0:
            repository.check_metadata()
            logging.info("Restic: Restic metadata for shared repository is valid.")

        if now.day == 1:
            repository.check_data()
            logging.info("Restic: Restic data for shared repository is valid.")

        EmailNotifier().notify(None)
    except Exception as e:
        logging.error("%s", e)
        EmailNotifier().notify(e)
