from pathlib import Path

from .command_runner import CommandRunner
from .local_runner import LocalRunner
from .ssh_runner import SshRunner
from .zfs_dataset import ZfsDataset


class RsyncPull:
    def __init__(
        self,
        source: ZfsDataset,
        destination_path: Path,
        rsync_runner: CommandRunner | None = None,
    ) -> None:
        self.source = source
        self.destination_path = destination_path
        self.rsync_runner = rsync_runner or LocalRunner()

    def pull(self, snapshot_name: str) -> None:
        if self.source.snapshot_exists(snapshot_name):
            self.source.destroy_snapshot(snapshot_name)

        self.source.create_snapshot(snapshot_name)
        try:
            snapshot_path = self.source.snapshot_path(snapshot_name)
            self.rsync_runner.run(["mkdir", "-p", str(self.destination_path)])

            source_ref = str(snapshot_path) + "/"
            rsync_cmd = ["rsync", "-a", "--delete"]

            if isinstance(self.source.runner, SshRunner):
                rsync_cmd += [
                    "-e",
                    self.source.runner.ssh_transport(),
                    self.source.runner.remote(source_ref),
                    f"{self.destination_path}/",
                ]
            else:
                rsync_cmd += [source_ref, f"{self.destination_path}/"]

            self.rsync_runner.run(rsync_cmd)
        finally:
            if self.source.snapshot_exists(snapshot_name):
                self.source.destroy_snapshot(snapshot_name)
