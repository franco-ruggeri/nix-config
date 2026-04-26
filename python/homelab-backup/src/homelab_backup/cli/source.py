from datetime import datetime
from pathlib import Path

from homelab_backup.core.restic_repository import ResticRepository
from homelab_backup.core.zfs_dataset import ZfsDataset
from homelab_backup.notifiers.email_notifier import EmailNotifier
from homelab_backup.runners.local_runner import LocalRunner

_RESTIC_REPOSITORY = Path("/mnt") / "zfs" / "k8s-backup"
_ZFS_DATASETS = ["zfs/k8s-nfs", "zfs/k8s-longhorn"]
_SNAPSHOT_NAME = "restic"


def _backup_dataset(zfs_dataset: ZfsDataset, restic_repository: ResticRepository) -> None:
    try:
        restic_repository.backup(zfs_dataset.snapshot_path(_SNAPSHOT_NAME))
    finally:
        zfs_dataset.destroy_snapshot(_SNAPSHOT_NAME)


def main() -> None:
    try:
        now = datetime.now()
        local_runner = LocalRunner()

        restic_repository = ResticRepository(path=_RESTIC_REPOSITORY)
        restic_repository.ensure_initialized()

        zfs_datasets = [ZfsDataset(name=name, runner=local_runner) for name in _ZFS_DATASETS]

        for dataset in zfs_datasets:
            dataset.create_snapshot(_SNAPSHOT_NAME)  # first, snapshot all ZFS datasets (fast)
        for dataset in zfs_datasets:
            _backup_dataset(dataset, restic_repository)  # then, backup all ZFS datasets one by one (slow)
        for dataset in zfs_datasets:
            restic_repository.verify_snapshot(dataset.snapshot_path(_SNAPSHOT_NAME))

        restic_repository.prune()

        if now.weekday() == 0:
            restic_repository.check_metadata()

        if now.day == 1:
            restic_repository.check_data()

        EmailNotifier().notify(None)
    except Exception as e:
        EmailNotifier().notify(e)
