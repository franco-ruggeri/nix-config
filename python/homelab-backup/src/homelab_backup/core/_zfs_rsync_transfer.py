import logging
from pathlib import Path

from homelab_backup.core._zfs_dataset import ZfsDataset
from homelab_backup.core._zfs_transfer import ZfsTransfer
from homelab_backup.shell._local_runner import LocalRunner
from homelab_backup.shell._ssh_runner import SshRunner


class ZfsRsyncTransfer(ZfsTransfer):
    def __init__(
        self,
        source: ZfsDataset,
        destination_path: Path,
    ) -> None:
        super().__init__(source=source)
        self._destination_path = destination_path
        self._rsync_runner = LocalRunner()

    def transfer(self) -> None:
        snapshot_name = f"{self._prefix}-current"
        self._source.create_snapshot(snapshot_name)
        try:
            snapshot_path = self._source.snapshot_path(snapshot_name)
            self._rsync_runner.run(["mkdir", "-p", str(self._destination_path)])

            source_ref = str(snapshot_path) + "/"
            rsync_cmd = ["rsync", "-a", "--delete"]

            assert isinstance(self._source.runner, SshRunner)
            rsync_cmd += [
                "-e",
                self._source.runner.ssh_transport(),
                self._source.runner.remote(source_ref),
                f"{self._destination_path}/",
            ]

            self._rsync_runner.run(rsync_cmd)
        except Exception:
            logging.exception("ZfsRsyncTransfer: transfer failed for %s", self._source.name)
            raise
        finally:
            self._source.destroy_snapshot(snapshot_name)
