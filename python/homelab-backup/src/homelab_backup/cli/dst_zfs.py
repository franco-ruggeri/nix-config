import os

from homelab_backup.cli._utils import BACKUP_DATASET
from homelab_backup.core import ZfsDataset, ZfsNativeTransfer
from homelab_backup.notifiers import EmailNotifier
from homelab_backup.runners import LocalRunner, SshRunner


def main() -> None:
    try:
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
        EmailNotifier().notify()
    except Exception as e:
        EmailNotifier().notify(e)
