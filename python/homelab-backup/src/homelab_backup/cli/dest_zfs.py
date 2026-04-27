import os
from datetime import datetime

from homelab_backup.cli._utils import BACKUP_DATASET
from homelab_backup.core import ResticRepository, ZfsDataset, ZfsNativeTransfer
from homelab_backup.shell import LocalRunner, SshRunner
from homelab_backup.smtp import EmailNotifier


def main() -> None:
    try:
        now = datetime.now()
        source = ZfsDataset(
            name=BACKUP_DATASET,
            runner=SshRunner(
                host=os.environ["SOURCE_HOST"],
                user=os.environ["SOURCE_USER"],
            ),
        )
        destination = ZfsDataset(name=BACKUP_DATASET, runner=LocalRunner())

        zfs_transfer = ZfsNativeTransfer(source=source, destination=destination)
        zfs_transfer.transfer()

        restic_repository = ResticRepository(path=destination.mountpoint)
        if now.weekday() == 0:
            restic_repository.check_metadata()
        if now.day == 1:
            restic_repository.check_data()

        EmailNotifier().notify()
    except Exception as e:
        EmailNotifier().notify(e)
