import os
from datetime import datetime
from pathlib import Path

from homelab_backup.cli._utils import BACKUP_DATASET
from homelab_backup.core import ResticRepository, ZfsDataset, ZfsRsyncTransfer
from homelab_backup.shell import SshRunner
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
        destination_path = Path(os.environ["RSYNC_DEST_PATH"]).expanduser()
        zfs_transfer = ZfsRsyncTransfer(
            source=source,
            destination_path=destination_path,
        )
        zfs_transfer.transfer()

        restic_repository_file = Path(os.environ["RESTIC_REPOSITORY_FILE"]).expanduser()
        restic_repository = ResticRepository(path=Path(restic_repository_file.read_text().strip()))
        if now.weekday() == 0:
            restic_repository.check_metadata()
        if now.day == 1:
            restic_repository.check_data()

        EmailNotifier().notify()
    except Exception as e:
        EmailNotifier().notify(e)
