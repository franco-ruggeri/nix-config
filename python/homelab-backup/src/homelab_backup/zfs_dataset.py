import logging
from pathlib import Path

from .command_runner import CommandRunner


class ZfsDataset:
    def __init__(self, name: str, runner: CommandRunner) -> None:
        self.name = name
        self.runner = runner

    def snapshot_ref(self, snapshot_name: str) -> str:
        return f"{self.name}@{snapshot_name}"

    def snapshot_exists(self, snapshot_name: str) -> bool:
        try:
            self.runner.run(
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
        self.runner.run(["zfs", "snapshot", snapshot])
        logging.info("ZFS: Created snapshot %s", snapshot)

    def destroy_snapshot(self, snapshot_name: str) -> None:
        snapshot = self.snapshot_ref(snapshot_name)
        self.runner.run(["zfs", "destroy", snapshot])
        logging.info("ZFS: Destroyed snapshot %s", snapshot)

    def rename_snapshot(self, old_name: str, new_name: str) -> None:
        old_ref = self.snapshot_ref(old_name)
        new_ref = self.snapshot_ref(new_name)
        self.runner.run(["zfs", "rename", old_ref, new_ref])
        logging.info("ZFS: Renamed snapshot %s -> %s", old_ref, new_ref)

    def mountpoint(self) -> Path:
        result = self.runner.run(
            [
                "zfs",
                "get",
                "-H",
                "-o",
                "value",
                "mountpoint",
                self.name,
            ],
            capture_output=True,
        )
        mountpoint = result.stdout.strip()
        if not mountpoint:
            raise Exception(f"Could not resolve mountpoint for dataset {self.name}.")
        return Path(mountpoint)

    def snapshot_path(self, snapshot_name: str) -> Path:
        return self.mountpoint() / ".zfs" / "snapshot" / snapshot_name
