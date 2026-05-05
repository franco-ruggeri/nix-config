import logging
from pathlib import Path

from homelab_backup.core._zfs_dataset import ZfsDataset
from homelab_backup.core._zfs_transfer import ZfsTransfer
from homelab_backup.shell._local_runner import LocalRunner
from homelab_backup.shell._ssh_runner import SshRunner


class ZfsRsyncTransfer(ZfsTransfer):
    def __init__(
        self,
        src: ZfsDataset,
        dst_path: Path,
    ) -> None:
        super().__init__(src=src)
        self._dst_path = dst_path
        self._rsync_runner = LocalRunner()

    def transfer(self) -> None:
        try:
            logging.info("ZFS: Starting ZFS rsync transfer for %s", self._src.name)

            snapshot_name = f"{self._hostname}-current"
            self._src.create_snapshot(snapshot_name)
            snapshot_path = self._src.snapshot_path(snapshot_name)
            self._rsync_runner.run(cmd=["mkdir", "-p", str(self._dst_path)])

            src_ref = str(snapshot_path) + "/"
            rsync_cmd = [
                "rsync",
                "--archive",
                "--delete-delay",
                "--numeric-ids",
                "--verbose",
            ]

            assert isinstance(self._src.runner, SshRunner)
            rsync_cmd += [
                "-e",
                self._src.runner.ssh_transport(),
                self._src.runner.remote(src_ref),
                f"{self._dst_path}/",
            ]

            self._rsync_runner.run(rsync_cmd)
        except Exception:
            logging.exception("ZFS: transfer failed for %s", self._src.name)
            raise
        finally:
            self._src.destroy_snapshot(snapshot_name)
