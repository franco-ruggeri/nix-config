from pathlib import Path

from homelab_backup.backup.zfs_dataset import ZfsDataset
from homelab_backup.execution.command_runner import CommandRunner
from homelab_backup.execution.local_runner import LocalRunner
from homelab_backup.transfer.dataset_transfer import DatasetTransfer


class RsyncPull(DatasetTransfer):
    def __init__(
        self,
        source: ZfsDataset,
        destination_path: Path,
        rsync_runner: CommandRunner | None = None,
    ) -> None:
        self._source = source
        self._destination_path = destination_path
        self._rsync_runner = rsync_runner or LocalRunner()

    def _pull(self, snapshot_name: str) -> None:
        if self._source.snapshot_exists(snapshot_name):
            self._source.destroy_snapshot(snapshot_name)
        self._source.create_snapshot(snapshot_name)
        try:
            snapshot_path = self._source.snapshot_path(snapshot_name)
            self._rsync_runner.run(["mkdir", "-p", str(self._destination_path)])

            source_ref = str(snapshot_path) + "/"
            rsync_cmd = ["rsync", "-a", "--delete"]

            if self._source.is_remote():
                rsync_cmd += [
                    "-e",
                    self._source.ssh_transport(),
                    self._source.remote(source_ref),
                    f"{self._destination_path}/",
                ]
            else:
                rsync_cmd += [source_ref, f"{self._destination_path}/"]

            self._rsync_runner.run(rsync_cmd)
        finally:
            if self._source.snapshot_exists(snapshot_name):
                self._source.destroy_snapshot(snapshot_name)

    def transfer(self, snapshot_prefix: str) -> None:
        self._pull(snapshot_name=f"{snapshot_prefix}-current")
