import logging
import os
from pathlib import Path

from homelab_backup.core import ZfsDataset, ZfsRsyncTransfer
from homelab_backup.notifiers import EmailNotifier
from homelab_backup.runners import LocalRunner, SshRunner

_BACKUP_DATASET = "zfs/k8s-backup"


def rsync_pull() -> None:
    source_host = os.environ["SOURCE_HOST"]
    source_user = os.environ["SOURCE_USER"]
    rsync_dest_path = Path(os.environ["RSYNC_DEST_PATH"]).expanduser()

    source = ZfsDataset(name=_BACKUP_DATASET, runner=SshRunner(host=source_host, user=source_user))
    transfer = ZfsRsyncTransfer(source=source, destination_path=rsync_dest_path, rsync_runner=LocalRunner())

    transfer.transfer()


def main() -> None:
    try:
        rsync_pull()
        EmailNotifier().notify()
    except Exception as e:
        logging.error("%s", e)
        EmailNotifier().notify(e)
