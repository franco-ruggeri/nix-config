from pathlib import Path

from homelab_backup.backup.zfs_dataset import ZfsDataset
from homelab_backup.execution.job_runner import JobRunner
from homelab_backup.execution.local_runner import LocalRunner
from homelab_backup.execution.notifier import Notifier
from homelab_backup.execution.ssh_runner import SshRunner
from homelab_backup.transfer.zfs_rsync_transfer import ZfsRsyncTransfer
from homelab_backup.utils import get_env


def _rsync_pull() -> None:
    source_dataset = get_env("SOURCE_DATASET")
    source_host = get_env("SOURCE_HOST")
    source_user = get_env("SOURCE_USER")
    rsync_dest_path = Path(get_env("RSYNC_DEST_PATH")).expanduser()

    source = ZfsDataset(name=source_dataset, runner=SshRunner(host=source_host, user=source_user))
    transfer = ZfsRsyncTransfer(source=source, destination_path=rsync_dest_path, rsync_runner=LocalRunner())

    transfer.transfer()


def main() -> None:
    job = JobRunner()
    job.run("rsync-pull", _rsync_pull)
    Notifier().notify(job.errors)
