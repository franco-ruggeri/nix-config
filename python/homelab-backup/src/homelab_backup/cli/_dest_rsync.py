import logging
import os
from pathlib import Path

from homelab_backup.cli._utils import BACKUP_DATASET
from homelab_backup.core import ZfsDataset, ZfsRsyncTransfer
from homelab_backup.notifiers import EmailNotifier
from homelab_backup.runners import LocalRunner, SshRunner


def main() -> None:
    try:
        source_host = os.environ["SOURCE_HOST"]
        source_user = os.environ["SOURCE_USER"]
        rsync_dest_path = Path(os.environ["RSYNC_DEST_PATH"]).expanduser()

        source = ZfsDataset(name=BACKUP_DATASET, runner=SshRunner(host=source_host, user=source_user))
        zfs_transfer = ZfsRsyncTransfer(source=source, destination_path=rsync_dest_path, rsync_runner=LocalRunner())
        zfs_transfer.transfer()

        EmailNotifier().notify()
    except Exception as e:
        logging.error("%s", e)
        EmailNotifier().notify(e)
