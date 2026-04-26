import logging
import os
import re
import smtplib
import socket
import subprocess
import sys
from datetime import datetime, timedelta
from email.message import EmailMessage
from pathlib import Path
from subprocess import CompletedProcess
from typing import Callable

MAX_AGE_HOURS = timedelta(hours=25)


_SMTP_SERVER = "smtp.gmail.com"
_SMTP_PORT = 465
_SMTP_USER = "franco.ruggeri.pro@gmail.com"
_EMAIL_RECIPIENT = _SMTP_USER


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


def run_and_log(run_fn: Callable[[], None], errors: list[str]) -> None:
    try:
        run_fn()
    except Exception as e:
        logging.error(str(e))
        errors.append(f"FAILED: {e}")


def notify(errors: list[str]) -> None:
    hostname = socket.gethostname()
    script = Path(sys.argv[0])
    result = "FAILED" if errors else "PASSED"

    subject = f"[Homelab] {result} - {hostname}"
    body_lines = [
        "Context:",
        f"- Hostname: {hostname}",
        f"- Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        f"- Script: {script.name}",
        f"- Result: {result}",
    ]
    if errors:
        body_lines += [
            "",
            "Errors:",
            *[f"- {e}" for e in errors],
        ]
    body = "\n".join(body_lines)

    msg = EmailMessage()
    msg["Subject"] = subject
    msg["From"] = _SMTP_USER
    msg["To"] = _EMAIL_RECIPIENT
    msg.set_content(body)

    with open(os.environ["SMTP_PASSWORD_FILE"], "r") as f:
        smtp_password = f.read()

    try:
        with smtplib.SMTP_SSL(_SMTP_SERVER, _SMTP_PORT) as smtp:
            smtp.login(_SMTP_USER, smtp_password)
            smtp.send_message(msg)
        logging.info("Email sent to %s", _EMAIL_RECIPIENT)
    except Exception as e:
        logging.error("Failed to send email: %s", e)
