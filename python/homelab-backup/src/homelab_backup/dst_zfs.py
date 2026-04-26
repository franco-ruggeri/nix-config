import logging

from .local_runner import LocalRunner
from .ssh_runner import SshRunner
from .utils import get_env, get_snapshot_prefix, notify, run_and_log
from .zfs_dataset import ZfsDataset
from .zfs_replication import ZfsReplication

_BACKUP_DATASETS = [
    "zfs/k8s-nfs-backup",
    "zfs/k8s-longhorn-backup",
]


def _pull_latest_snapshot_for_dataset(source_dataset: str) -> None:
    source_host = get_env("SOURCE_HOST")
    source_user = get_env("SOURCE_USER")
    source = ZfsDataset(name=source_dataset, runner=SshRunner(host=source_host, user=source_user))
    destination = ZfsDataset(name=source_dataset, runner=LocalRunner())
    transfer = ZfsReplication(source=source, destination=destination)

    prefix = get_snapshot_prefix()

    logging.info("Using snapshot prefix for %s: %s", source_dataset, prefix)
    transfer.transfer(prefix)


def pull_latest_snapshot() -> None:
    for backup_dataset in _BACKUP_DATASETS:
        _pull_latest_snapshot_for_dataset(backup_dataset)


def main() -> None:
    errors: list[str] = []
    run_and_log(run_fn=pull_latest_snapshot, errors=errors)
    notify(errors)
