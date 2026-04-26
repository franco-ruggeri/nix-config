import logging
import os

from homelab_backup.core.zfs_dataset import ZfsDataset
from homelab_backup.core.zfs_native_transfer import ZfsNativeTransfer
from homelab_backup.notifiers.email_notifier import EmailNotifier
from homelab_backup.runners.local_runner import LocalRunner
from homelab_backup.runners.ssh_runner import SshRunner

_BACKUP_DATASETS = ["zfs/k8s-backup"]


def _pull_latest_snapshot_for_dataset(source_dataset: str) -> None:
    source_host = os.environ["SOURCE_HOST"]
    source_user = os.environ["SOURCE_USER"]
    source = ZfsDataset(name=source_dataset, runner=SshRunner(host=source_host, user=source_user))
    destination = ZfsDataset(name=source_dataset, runner=LocalRunner())
    transfer = ZfsNativeTransfer(source=source, destination=destination)

    logging.info("Starting ZFS replication for %s", source_dataset)
    transfer.transfer()


def pull_latest_snapshot() -> None:
    for backup_dataset in _BACKUP_DATASETS:
        _pull_latest_snapshot_for_dataset(backup_dataset)


def main() -> None:
    try:
        pull_latest_snapshot()
        EmailNotifier().notify(None)
    except Exception as e:
        logging.error("%s", e)
        EmailNotifier().notify(e)
