import json
import logging
import os
from datetime import datetime, timedelta, timezone
from pathlib import Path
from subprocess import CompletedProcess
from typing import Any

from homelab_backup.execution.local_runner import LocalRunner


class ResticRepository:
    def __init__(self, path: Path, runner: LocalRunner | None = None) -> None:
        self.path = path
        self.runner = runner if runner is not None else LocalRunner()

    def _set_env(self) -> None:
        os.environ["RESTIC_REPOSITORY"] = str(self.path)
        os.environ["RESTIC_CACHE_DIR"] = "/tmp/restic-cache"
        os.environ["RESTIC_PROGRESS_FPS"] = str(1 / 60)
        os.environ["RESTIC_FEATURES"] = "device-id-for-hardlinks"

    def _run(
        self,
        cmd: list[str],
        capture_output: bool = False,
        cwd: Path | None = None,
    ) -> CompletedProcess[str]:
        self._set_env()
        return self.runner.run(cmd, capture_output=capture_output, cwd=cwd)

    def ensure_initialized(self) -> None:
        self._set_env()
        try:
            self.runner.run(["restic", "cat", "config"])
        except Exception:
            self.runner.run(["restic", "init"])
            logging.info("Restic: Initialized repository %s", self.path)

    def backup(self, path: Path) -> None:
        self._run(["restic", "backup", "."], cwd=path)

    def prune(self) -> None:
        self._run(
            [
                "restic",
                "forget",
                "--keep-daily=7",
                "--keep-weekly=4",
                "--keep-monthly=6",
                "--prune",
            ]
        )

    def _latest_snapshot(self, path: Path) -> dict[str, Any]:
        cmd = ["restic", "snapshots", "--json", "--path", str(path)]
        result = self._run(cmd, capture_output=True)
        snapshots = json.loads(result.stdout)
        if not snapshots:
            raise Exception(f"Restic: No restic snapshots found for {path}.")
        return max(snapshots, key=lambda snapshot: snapshot["time"])

    def verify_recent_snapshot(self, max_age: timedelta, path: Path) -> None:
        latest = self._latest_snapshot(path)
        dt = datetime.fromisoformat(latest["time"].replace("Z", "+00:00"))
        if datetime.now(timezone.utc) - dt > max_age:
            raise Exception(f"Restic: Snapshot is too old for {path}.")

    def verify_latest_snapshot_nonzero(self, path: Path) -> None:
        latest = self._latest_snapshot(path)
        size = latest.get("summary", {}).get("total_bytes_processed", 0)
        if size == 0:
            raise Exception(f"Restic: Snapshot size is 0 for {path}.")

    def check_metadata(self) -> None:
        self._run(["restic", "check"])

    def check_data(self) -> None:
        self._run(["restic", "check", "--read-data"])
