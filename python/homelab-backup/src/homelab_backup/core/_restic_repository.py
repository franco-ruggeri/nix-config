import json
import logging
import os
from datetime import datetime, timedelta, timezone
from pathlib import Path
from subprocess import CompletedProcess

from homelab_backup.shell._local_runner import LocalRunner


class ResticRepository:
    _MAX_AGE = timedelta(hours=25)

    def __init__(self, path: Path) -> None:
        self._path = path
        self._runner = LocalRunner()

    def _run(
        self,
        cmd: list[str],
        capture_output: bool = False,
        cwd: Path | None = None,
    ) -> CompletedProcess[str]:
        os.environ["RESTIC_REPOSITORY"] = str(self._path)
        os.environ["RESTIC_CACHE_DIR"] = "/tmp/restic-cache"
        os.environ["RESTIC_PROGRESS_FPS"] = str(1 / 60)
        os.environ["RESTIC_FEATURES"] = "device-id-for-hardlinks"
        return self._runner.run(cmd=cmd, capture_output=capture_output, cwd=cwd)

    def ensure_initialized(self) -> None:
        try:
            self._run(["restic", "cat", "config"])
        except Exception:
            self._run(["restic", "init"])
            logging.info("Restic: Initialized repository %s", self._path)

    def backup(self, path: Path) -> None:
        logging.info("Restic: Backing up %s...", path)
        self._run(cmd=["restic", "backup", "."], cwd=path)
        logging.info("Restic: Backup of %s completed.", path)

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
        logging.info("Restic: Pruned old snapshots from shared repository.")

    def verify_snapshot(self, path: Path) -> None:
        result = self._run(
            cmd=["restic", "snapshots", "--json", "--path", str(path)],
            capture_output=True,
        )
        snapshots = json.loads(result.stdout)
        if not snapshots:
            raise Exception(f"Restic: No restic snapshots found for {path}.")
        latest = max(snapshots, key=lambda snapshot: snapshot["time"])
        dt = datetime.fromisoformat(latest["time"].replace("Z", "+00:00"))
        if datetime.now(timezone.utc) - dt > self._MAX_AGE:
            raise Exception(f"Restic: Snapshot is too old for {path}.")
        size = latest.get("summary", {}).get("total_bytes_processed", 0)
        if size == 0:
            raise Exception(f"Restic: Snapshot size is 0 for {path}.")
        logging.info("Restic: Found valid snapshot for %s.", path)

    def check_metadata(self) -> None:
        self._run(["restic", "check"])
        logging.info("Restic: Metadata for shared repository is valid.")

    def check_data(self) -> None:
        self._run(["restic", "check", "--read-data"])
        logging.info("Restic: Data for shared repository is valid.")
