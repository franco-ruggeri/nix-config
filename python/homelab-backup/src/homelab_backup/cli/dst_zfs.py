import logging

from homelab_backup.backup.zfs_dataset import ZfsDataset
from homelab_backup.execution.job_runner import JobRunner
from homelab_backup.execution.local_runner import LocalRunner
from homelab_backup.execution.notifier import Notifier
from homelab_backup.execution.ssh_runner import SshRunner
from homelab_backup.transfer.zfs_native_transfer import ZfsNativeTransfer
from homelab_backup.utils import get_env

_BACKUP_DATASETS = [
    "zfs/k8s-backup",
]


def _pull_latest_snapshot_for_dataset(source_dataset: str) -> None:
    source_host = get_env("SOURCE_HOST")
    source_user = get_env("SOURCE_USER")
    source = ZfsDataset(name=source_dataset, runner=SshRunner(host=source_host, user=source_user))
    destination = ZfsDataset(name=source_dataset, runner=LocalRunner())
    transfer = ZfsNativeTransfer(source=source, destination=destination)

    logging.info("Starting ZFS replication for %s", source_dataset)
    transfer.transfer()


def pull_latest_snapshot() -> None:
    for backup_dataset in _BACKUP_DATASETS:
        _pull_latest_snapshot_for_dataset(backup_dataset)


def main() -> None:
    job = JobRunner()
    job.run("zfs-pull", pull_latest_snapshot)
    Notifier().notify(job.errors)
