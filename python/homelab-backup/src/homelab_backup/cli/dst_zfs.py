import os
from datetime import datetime

from homelab_backup.cli._utils import BACKUP_DATASET
from homelab_backup.core import ResticRepository, ZfsDataset, ZfsNativeTransfer
from homelab_backup.shell import LocalRunner, SshRunner
from homelab_backup.smtp import EmailNotifier


def main() -> None:
    try:
        src = ZfsDataset(
            name=BACKUP_DATASET,
            runner=SshRunner(
                host=os.environ["SRC_HOST"],
                user=os.environ["SRC_USER"],
            ),
        )
        dst = ZfsDataset(name=BACKUP_DATASET, runner=LocalRunner())

        zfs_transfer = ZfsNativeTransfer(src=src, dst=dst)
        zfs_transfer.transfer()

        restic_repository = ResticRepository(path=dst.mountpoint)
        restic_repository.check_metadata()
        if datetime.now().day == 1:
            restic_repository.check_data()

        EmailNotifier().notify()
    except Exception as e:
        EmailNotifier().notify(e)
