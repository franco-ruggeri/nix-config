from pathlib import Path

from .domain import LocalRunner, RsyncPull, SshRunner, ZfsDataset
from .utils import get_env, get_snapshot_prefix, notify, run_and_log


def _rsync_pull() -> None:
    source_dataset = get_env("SOURCE_DATASET")
    source_host = get_env("SOURCE_HOST")
    source_user = get_env("SOURCE_USER")
    rsync_dest_path = Path(get_env("RSYNC_DEST_PATH")).expanduser()

    snapshot_prefix = get_snapshot_prefix()
    snapshot_name = f"{snapshot_prefix}-current"
    source = ZfsDataset(name=source_dataset, runner=SshRunner(host=source_host, user=source_user))
    pull = RsyncPull(source=source, destination_path=rsync_dest_path, rsync_runner=LocalRunner())

    pull.pull(snapshot_name=snapshot_name)


def main() -> None:
    errors: list[str] = []
    run_and_log(run_fn=_rsync_pull, errors=errors)
    notify(errors)
