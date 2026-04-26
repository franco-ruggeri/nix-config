import logging
import os
from pathlib import Path

from homelab_backup.backup.zfs_dataset import ZfsDataset
from homelab_backup.execution.local_runner import LocalRunner
from homelab_backup.execution.notifier import Notifier
from homelab_backup.execution.ssh_runner import SshRunner
from homelab_backup.transfer.zfs_rsync_transfer import ZfsRsyncTransfer


def _rsync_pull() -> None:
    source_dataset = os.environ["SOURCE_DATASET"]
    source_host = os.environ["SOURCE_HOST"]
    source_user = os.environ["SOURCE_USER"]
    rsync_dest_path = Path(os.environ["RSYNC_DEST_PATH"]).expanduser()

    source = ZfsDataset(name=source_dataset, runner=SshRunner(host=source_host, user=source_user))
    transfer = ZfsRsyncTransfer(source=source, destination_path=rsync_dest_path, rsync_runner=LocalRunner())

    transfer.transfer()


def main() -> None:
    try:
        _rsync_pull()
        Notifier().notify(None)
    except Exception as e:
        logging.error("%s", e)
        Notifier().notify(e)
