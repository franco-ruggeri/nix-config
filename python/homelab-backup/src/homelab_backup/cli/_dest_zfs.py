import logging
import os

from homelab_backup.cli._utils import BACKUP_DATASET
from homelab_backup.core import ZfsDataset, ZfsNativeTransfer
from homelab_backup.notifiers import EmailNotifier
from homelab_backup.runners import LocalRunner, SshRunner


def main() -> None:
    try:
        source_host = os.environ["SOURCE_HOST"]
        source_user = os.environ["SOURCE_USER"]
        source = ZfsDataset(name=BACKUP_DATASET, runner=SshRunner(host=source_host, user=source_user))
        destination = ZfsDataset(name=BACKUP_DATASET, runner=LocalRunner())
        zfs_transfer = ZfsNativeTransfer(source=source, destination=destination)

        logging.info("Starting ZFS replication for %s", BACKUP_DATASET)
        zfs_transfer.transfer()

        EmailNotifier().notify()
    except Exception as e:
        logging.error("%s", e)
        EmailNotifier().notify(e)
