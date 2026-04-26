from pathlib import Path

from ..datasets.zfs_dataset import ZfsDataset
from ..execution.local_runner import LocalRunner
from ..execution.ssh_runner import SshRunner
from ..transfer.rsync_pull import RsyncPull
from ..utils import get_env, get_snapshot_prefix, notify, run_and_log


def _rsync_pull() -> None:
    source_dataset = get_env("SOURCE_DATASET")
    source_host = get_env("SOURCE_HOST")
    source_user = get_env("SOURCE_USER")
    rsync_dest_path = Path(get_env("RSYNC_DEST_PATH")).expanduser()

    snapshot_prefix = get_snapshot_prefix()
    source = ZfsDataset(name=source_dataset, runner=SshRunner(host=source_host, user=source_user))
    transfer = RsyncPull(source=source, destination_path=rsync_dest_path, rsync_runner=LocalRunner())

    transfer.transfer(snapshot_prefix=snapshot_prefix)


def main() -> None:
    errors: list[str] = []
    run_and_log(run_fn=_rsync_pull, errors=errors)
    notify(errors)
