from datetime import datetime

from homelab_backup.cli._utils import BACKUP_DATASET
from homelab_backup.core import ResticRepository, ZfsDataset
from homelab_backup.shell import LocalRunner
from homelab_backup.smtp import EmailNotifier

_ZFS_DATASETS = ["zfs/k8s-nfs", "zfs/k8s-longhorn"]
_SNAPSHOT_NAME = "restic"


def main() -> None:
    try:
        now = datetime.now()
        local_runner = LocalRunner()
        backup_dataset = ZfsDataset(name=BACKUP_DATASET, runner=local_runner)

        restic_path = backup_dataset.mountpoint
        restic_repository = ResticRepository(path=restic_path)
        restic_repository.ensure_initialized()

        zfs_datasets = [ZfsDataset(name=name, runner=local_runner) for name in _ZFS_DATASETS]
        for zfs_dataset in zfs_datasets:  # first, create snapshot for all ZFS datasets (fast)
            zfs_dataset.create_snapshot(_SNAPSHOT_NAME)
        for zfs_dataset in zfs_datasets:  # then, backup all ZFS datasets one by one (slow)
            restic_repository.backup(zfs_dataset.snapshot_path(_SNAPSHOT_NAME))
            restic_repository.verify_snapshot(zfs_dataset.snapshot_path(_SNAPSHOT_NAME))
            zfs_dataset.destroy_snapshot(_SNAPSHOT_NAME)
        restic_repository.prune()

        restic_repository.check_metadata()
        if now.day == 1:
            restic_repository.check_data()

        EmailNotifier().notify()
    except Exception as e:
        EmailNotifier().notify(e)
