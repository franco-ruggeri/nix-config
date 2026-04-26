import logging
import os

from homelab_backup.core import ZfsDataset, ZfsNativeTransfer
from homelab_backup.notifiers import EmailNotifier
from homelab_backup.runners import LocalRunner, SshRunner

_BACKUP_DATASET = "zfs/k8s-backup"


def pull_latest_snapshot() -> None:
    source_host = os.environ["SOURCE_HOST"]
    source_user = os.environ["SOURCE_USER"]
    source = ZfsDataset(name=_BACKUP_DATASET, runner=SshRunner(host=source_host, user=source_user))
    destination = ZfsDataset(name=_BACKUP_DATASET, runner=LocalRunner())
    transfer = ZfsNativeTransfer(source=source, destination=destination)

    logging.info("Starting ZFS replication for %s", _BACKUP_DATASET)
    transfer.transfer()


def main() -> None:
    try:
        pull_latest_snapshot()
        EmailNotifier().notify()
    except Exception as e:
        logging.error("%s", e)
        EmailNotifier().notify(e)
