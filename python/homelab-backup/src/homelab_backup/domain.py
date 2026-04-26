import json
import logging
import os
import shlex
import subprocess
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from pathlib import Path
from subprocess import CompletedProcess
from typing import Protocol

from .utils import build_ssh_cmd, run_shell_cmd


class CommandRunner(Protocol):
    def build_command(self, cmd: list[str]) -> list[str]:
        ...

    def run(
        self,
        cmd: list[str],
        capture_output: bool = False,
        cwd: Path | None = None,
    ) -> CompletedProcess:
        ...


@dataclass(frozen=True)
class LocalRunner:
    def build_command(self, cmd: list[str]) -> list[str]:
        return cmd

    def run(
        self,
        cmd: list[str],
        capture_output: bool = False,
        cwd: Path | None = None,
    ) -> CompletedProcess:
        return run_shell_cmd(cmd, capture_output=capture_output, cwd=cwd)


@dataclass(frozen=True)
class SshRunner:
    host: str
    user: str

    def build_command(self, cmd: list[str]) -> list[str]:
        return build_ssh_cmd() + [f"{self.user}@{self.host}"] + cmd

    def run(
        self,
        cmd: list[str],
        capture_output: bool = False,
        cwd: Path | None = None,
    ) -> CompletedProcess:
        if cwd is not None:
            raise Exception("cwd is not supported for remote commands.")
        return run_shell_cmd(self.build_command(cmd), capture_output=capture_output)

    def ssh_transport(self) -> str:
        return " ".join(shlex.quote(part) for part in build_ssh_cmd())

    def remote(self, path: str | Path) -> str:
        return f"{self.user}@{self.host}:{path}"


@dataclass(frozen=True)
class ZfsDataset:
    name: str
    runner: CommandRunner

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


@dataclass(frozen=True)
class ResticRepository:
    path: Path

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

    def latest_snapshot(self) -> dict:
        result = self._run(["restic", "snapshots", "--json"], capture_output=True)
        snapshots = json.loads(result.stdout)
        if not snapshots:
            raise Exception(f"Restic: No restic snapshots found for {self.path}.")
        return max(snapshots, key=lambda snapshot: snapshot["time"])

    def verify_recent_snapshot(self, max_age: timedelta) -> None:
        latest = self.latest_snapshot()
        dt = datetime.fromisoformat(latest["time"].replace("Z", "+00:00"))
        if datetime.now(timezone.utc) - dt > max_age:
            raise Exception(f"Restic: Snapshot is too old for {self.path}.")

    def verify_latest_snapshot_nonzero(self) -> None:
        latest = self.latest_snapshot()
        size = latest.get("summary", {}).get("total_bytes_processed", 0)
        if size == 0:
            raise Exception(f"Restic: Snapshot size is 0 for {self.path}.")

    def check_metadata(self) -> None:
        self._run(["restic", "check"])

    def check_data(self) -> None:
        self._run(["restic", "check", "--read-data"])


@dataclass(frozen=True)
class DatasetBackup:
    dataset: ZfsDataset
    repository: ResticRepository

    def run_backup_cycle(self, snapshot_name: str = "restic") -> None:
        self.dataset.create_snapshot(snapshot_name)
        primary_error: Exception | None = None

        try:
            self.repository.ensure_initialized()
            snapshot_path = self.dataset.snapshot_path(snapshot_name)
            logging.info("Restic: Backing up %s...", self.dataset.name)
            self.repository.backup_directory(snapshot_path)
            logging.info("Restic: Backup of %s completed.", self.dataset.name)
            self.repository.forget_prune()
            logging.info("Restic: Pruned old snapshots for %s.", self.dataset.name)
        except Exception as error:
            primary_error = error
            raise
        finally:
            try:
                if self.dataset.snapshot_exists(snapshot_name):
                    self.dataset.destroy_snapshot(snapshot_name)
            except Exception as cleanup_error:
                logging.error(
                    "Failed to cleanup snapshot %s for %s: %s",
                    snapshot_name,
                    self.dataset.name,
                    cleanup_error,
                )
                if primary_error is None:
                    raise

    def verify_recent_snapshot(self, max_age: timedelta) -> None:
        self.repository.verify_recent_snapshot(max_age)

    def verify_latest_snapshot_nonzero(self) -> None:
        self.repository.verify_latest_snapshot_nonzero()

    def check_repository_metadata(self) -> None:
        self.repository.check_metadata()

    def check_repository_data(self) -> None:
        self.repository.check_data()


@dataclass(frozen=True)
class ZfsReplication:
    source: ZfsDataset
    destination: ZfsDataset

    def replicate(self, prefix: str) -> None:
        last_name = f"{prefix}-last"
        current_name = f"{prefix}-current"

        if self.source.snapshot_exists(current_name):
            self.source.destroy_snapshot(current_name)
        self.source.create_snapshot(current_name)

        source_last = self.source.snapshot_ref(last_name)
        source_current = self.source.snapshot_ref(current_name)
        has_source_last = self.source.snapshot_exists(last_name)
        has_dest_last = self.destination.snapshot_exists(last_name)
        use_incremental = has_source_last and has_dest_last

        send_cmd = ["zfs", "send"]
        if use_incremental:
            send_cmd += ["-I", source_last]
            logging.info(
                "Running incremental replication for %s from %s to %s",
                self.source.name,
                source_last,
                source_current,
            )
        else:
            logging.info("Running full replication for %s", source_current)
        send_cmd += [source_current]

        send_proc = subprocess.Popen(
            self.source.runner.build_command(send_cmd),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        recv_proc = subprocess.Popen(
            self.destination.runner.build_command(["zfs", "receive", "-F", self.destination.name]),
            stdin=send_proc.stdout,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        if send_proc.stdout:
            send_proc.stdout.close()

        recv_stdout, recv_stderr = recv_proc.communicate()
        send_stderr = send_proc.stderr.read() if send_proc.stderr else b""
        send_rc = send_proc.wait()

        if send_rc != 0:
            raise Exception(f"zfs send failed:\n{send_stderr.decode(errors='replace')}")
        if recv_proc.returncode != 0:
            raise Exception(f"zfs receive failed:\n{recv_stderr.decode(errors='replace')}")
        if recv_stdout:
            logging.info(recv_stdout.decode(errors="replace").strip())

        if self.destination.snapshot_exists(last_name):
            self.destination.destroy_snapshot(last_name)
        self.destination.rename_snapshot(current_name, last_name)

        if self.source.snapshot_exists(last_name):
            self.source.destroy_snapshot(last_name)
        self.source.rename_snapshot(current_name, last_name)


@dataclass(frozen=True)
class RsyncPull:
    source: ZfsDataset
    destination_path: Path
    rsync_runner: CommandRunner = LocalRunner()

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
