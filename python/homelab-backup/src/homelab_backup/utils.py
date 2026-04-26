import logging
import os
import subprocess
from datetime import timedelta
from pathlib import Path
from subprocess import CompletedProcess

MAX_AGE_HOURS = timedelta(hours=25)


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
