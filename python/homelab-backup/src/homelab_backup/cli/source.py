from datetime import datetime
from pathlib import Path

from homelab_backup.core.restic_repository import ResticRepository
from homelab_backup.core.zfs_dataset import ZfsDataset
from homelab_backup.notifiers.email_notifier import EmailNotifier
from homelab_backup.runners.local_runner import LocalRunner

_RESTIC_REPOSITORY = Path("/mnt") / "zfs" / "k8s-backup"
_ZFS_DATASETS = ["zfs/k8s-nfs", "zfs/k8s-longhorn"]
_SNAPSHOT_NAME = "restic"


def main() -> None:
    try:
        now = datetime.now()
        local_runner = LocalRunner()

        restic_repository = ResticRepository(path=_RESTIC_REPOSITORY)
        restic_repository.ensure_initialized()

        zfs_datasets = [ZfsDataset(name=name, runner=local_runner) for name in _ZFS_DATASETS]

        for zfs_dataset in zfs_datasets:  # first, create snapshot for all ZFS datasets (fast)
            zfs_dataset.create_snapshot(_SNAPSHOT_NAME)
        for zfs_dataset in zfs_datasets:  # then, backup all ZFS datasets one by one (slow)
            restic_repository.backup(zfs_dataset.snapshot_path(_SNAPSHOT_NAME))
            restic_repository.verify_snapshot(zfs_dataset.snapshot_path(_SNAPSHOT_NAME))
            zfs_dataset.destroy_snapshot(_SNAPSHOT_NAME)

        restic_repository.prune()

        if now.weekday() == 0:
            restic_repository.check_metadata()

        if now.day == 1:
            restic_repository.check_data()

        EmailNotifier().notify()
    except Exception as e:
        EmailNotifier().notify(e)
