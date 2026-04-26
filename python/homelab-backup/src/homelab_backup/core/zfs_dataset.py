import logging
from pathlib import Path

from homelab_backup.runners.runner import Runner
from homelab_backup.runners.ssh_runner import SshRunner


class ZfsDataset:
    def __init__(self, name: str, runner: Runner) -> None:
        self._name = name
        self._runner = runner

    @property
    def name(self) -> str:
        return self._name

    @property
    def runner(self) -> Runner:
        return self._runner

    def is_remote(self) -> bool:
        return isinstance(self._runner, SshRunner)

    def snapshot_ref(self, snapshot_name: str) -> str:
        return f"{self._name}@{snapshot_name}"

    def snapshot_exists(self, snapshot_name: str) -> bool:
        try:
            self._runner.run(
                [
                    "zfs",
                    "list",
                    "-H",
                    "-t",
                    "snapshot",
                    "-o",
                    "name",
                    self.snapshot_ref(snapshot_name),
                ],
                capture_output=True,
            )
            return True
        except Exception:
            return False

    def create_snapshot(self, snapshot_name: str) -> None:
        snapshot = self.snapshot_ref(snapshot_name)
        if self.snapshot_exists(snapshot_name):
            self._runner.run(["zfs", "destroy", snapshot])
            logging.info("ZFS: Destroyed existing snapshot %s before recreating", snapshot)
        self._runner.run(["zfs", "snapshot", snapshot])
        logging.info("ZFS: Created snapshot %s", snapshot)

    def destroy_snapshot(self, snapshot_name: str) -> None:
        snapshot = self.snapshot_ref(snapshot_name)
        if not self.snapshot_exists(snapshot_name):
            logging.debug("ZFS: Snapshot %s does not exist, skipping destroy", snapshot)
            return
        self._runner.run(["zfs", "destroy", snapshot])
        logging.info("ZFS: Destroyed snapshot %s", snapshot)

    def rename_snapshot(self, old_name: str, new_name: str) -> None:
        old_ref = self.snapshot_ref(old_name)
        new_ref = self.snapshot_ref(new_name)
        self._runner.run(["zfs", "rename", old_ref, new_ref])
        logging.info("ZFS: Renamed snapshot %s -> %s", old_ref, new_ref)

    def _mountpoint(self) -> Path:
        result = self._runner.run(
            [
                "zfs",
                "get",
                "-H",
                "-o",
                "value",
                "mountpoint",
                self._name,
            ],
            capture_output=True,
        )
        mountpoint = result.stdout.strip()
        if not mountpoint:
            raise Exception(f"Could not resolve mountpoint for dataset {self._name}.")
        return Path(mountpoint)

    def snapshot_path(self, snapshot_name: str) -> Path:
        return self._mountpoint() / ".zfs" / "snapshot" / snapshot_name
