import json
import logging
import os
from datetime import datetime, timedelta, timezone
from pathlib import Path
from subprocess import CompletedProcess

from ..utils import run_shell_cmd


class ResticRepository:
    def __init__(self, path: Path) -> None:
        self.path = path

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
    ) -> CompletedProcess:
        self._set_env()
        return run_shell_cmd(cmd, capture_output=capture_output, cwd=cwd)

    def ensure_initialized(self) -> None:
        self._set_env()
        try:
            run_shell_cmd(["restic", "cat", "config"])
        except Exception:
            run_shell_cmd(["restic", "init"])
            logging.info("Restic: Initialized repository %s", self.path)

    def backup_directory(self, directory: Path) -> None:
        self._run(["restic", "backup", "."], cwd=directory)

    def forget_prune(self) -> None:
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

    def latest_snapshot(self, path: Path | None = None) -> dict:
        cmd = ["restic", "snapshots", "--json"]
        if path is not None:
            cmd += ["--path", str(path)]
        result = self._run(cmd, capture_output=True)
        snapshots = json.loads(result.stdout)
        if not snapshots:
            label = str(path) if path is not None else str(self.path)
            raise Exception(f"Restic: No restic snapshots found for {label}.")
        return max(snapshots, key=lambda snapshot: snapshot["time"])

    def verify_recent_snapshot(self, max_age: timedelta, path: Path | None = None) -> None:
        latest = self.latest_snapshot(path=path)
        dt = datetime.fromisoformat(latest["time"].replace("Z", "+00:00"))
        if datetime.now(timezone.utc) - dt > max_age:
            label = str(path) if path is not None else str(self.path)
            raise Exception(f"Restic: Snapshot is too old for {label}.")

    def verify_latest_snapshot_nonzero(self, path: Path | None = None) -> None:
        latest = self.latest_snapshot(path=path)
        size = latest.get("summary", {}).get("total_bytes_processed", 0)
        if size == 0:
            label = str(path) if path is not None else str(self.path)
            raise Exception(f"Restic: Snapshot size is 0 for {label}.")

    def check_metadata(self) -> None:
        self._run(["restic", "check"])

    def check_data(self) -> None:
        self._run(["restic", "check", "--read-data"])
