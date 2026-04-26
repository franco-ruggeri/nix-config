import logging
import os
import re
import subprocess
from datetime import timedelta
from pathlib import Path
from subprocess import CompletedProcess

MAX_AGE_HOURS = timedelta(hours=25)


logging.basicConfig(level=logging.INFO)


def run_shell_cmd(
    cmd: list[str],
    capture_output: bool = False,
    cwd: Path | None = None,
) -> CompletedProcess[str]:
    cmd_str = " ".join(cmd)
    logging.debug(f"Running: {cmd_str} (cwd={cwd})")

    result = subprocess.run(
        args=cmd,
        capture_output=capture_output,
        text=True,
        cwd=cwd,
    )

    if result.returncode != 0:
        raise Exception(f"Command failed: {cmd_str}\n{result.stderr}")

    return result


def get_env(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        raise Exception(f"{name} environment variable not set.")
    return value


def build_ssh_cmd() -> list[str]:
    cmd = [
        "ssh",
        "-o",
        "BatchMode=yes",
        "-o",
        "StrictHostKeyChecking=accept-new",
    ]
    ssh_private_key_file = os.environ.get("SSH_PRIVATE_KEY_FILE")
    if ssh_private_key_file:
        cmd += [
            "-i",
            ssh_private_key_file,
        ]
    return cmd


def get_snapshot_prefix() -> str:
    raw_hostname = run_shell_cmd(["hostname", "-s"], capture_output=True).stdout.strip()
    if not raw_hostname:
        raise Exception("Could not determine local hostname for snapshot prefix.")

    prefix = re.sub(r"[^a-zA-Z0-9:_\-\.]", "-", raw_hostname)
    if not prefix:
        raise Exception("Resolved snapshot prefix is empty.")
    return prefix


def run_ssh_cmd(source_host: str, source_user: str, remote_cmd: list[str]) -> CompletedProcess[str]:
    return run_shell_cmd(
        build_ssh_cmd() + [f"{source_user}@{source_host}"] + remote_cmd,
    )


def remote_snapshot_exists(
    source_host: str,
    source_user: str,
    dataset: str,
    snapshot_name: str,
) -> bool:
    snapshot = f"{dataset}@{snapshot_name}"
    try:
        run_ssh_cmd(
            source_host=source_host,
            source_user=source_user,
            remote_cmd=[
                "zfs",
                "list",
                "-H",
                "-t",
                "snapshot",
                "-o",
                "name",
                snapshot,
            ],
        )
        return True
    except Exception:
        return False
