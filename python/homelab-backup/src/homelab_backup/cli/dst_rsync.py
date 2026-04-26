import logging
import os
from pathlib import Path

from homelab_backup.cli._utils import BACKUP_DATASET
from homelab_backup.core import ZfsDataset, ZfsRsyncTransfer
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
        destination_path = Path(os.environ["RSYNC_DEST_PATH"]).expanduser()
        zfs_transfer = ZfsRsyncTransfer(
            source=source,
            destination_path=destination_path,
            rsync_runner=LocalRunner(),
        )
        zfs_transfer.transfer()
        EmailNotifier().notify()
    except Exception as e:
        logging.error("%s", e)
        EmailNotifier().notify(e)
