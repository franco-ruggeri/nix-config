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
        snapshot_path = dataset.snapshot_path(snapshot_name)
        repository.backup(snapshot_path)
    except Exception as error:
        primary_error = error
        raise
    finally:
        try:
            if dataset.snapshot_exists(snapshot_name):
                dataset.destroy_snapshot(snapshot_name)
        except Exception as cleanup_error:
            if primary_error is None:
                raise cleanup_error


def main() -> None:
    try:
        now = datetime.now()
        local_runner = LocalRunner()

        restic_repository = ResticRepository(path=_RESTIC_REPOSITORY)
        restic_repository.ensure_initialized()

        zfs_datasets = [ZfsDataset(name=zfs_dataset, runner=local_runner) for zfs_dataset in _ZFS_DATASETS]

        for dataset in zfs_datasets:
            dataset.create_snapshot(_SNAPSHOT_NAME)  # first, snapshot all ZFS datasets (fast)
        for dataset in zfs_datasets:
            _backup_dataset(dataset, restic_repository)  # then, backup all ZFS datasets one by one (slow)

        restic_repository.prune()

        for dataset in zfs_datasets:
            restic_repository.verify_snapshot(dataset.snapshot_path(_SNAPSHOT_NAME))

        if now.weekday() == 0:
            restic_repository.check_metadata()

        if now.day == 1:
            restic_repository.check_data()

        EmailNotifier().notify(None)
    except Exception as e:
        EmailNotifier().notify(e)
