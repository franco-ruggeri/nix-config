import logging
import os
import smtplib
import socket
import subprocess
import sys
from datetime import datetime, timedelta
from email.message import EmailMessage
from pathlib import Path
from subprocess import CompletedProcess
from typing import Callable

ZFS_DATASETS = {"k8s-nfs", "k8s-longhorn"}
MAX_AGE_HOURS = timedelta(hours=25)


_SMTP_SERVER = "smtp.gmail.com"
_SMTP_PORT = 465
_SMTP_USER = "franco.ruggeri.pro@gmail.com"
_EMAIL_RECIPIENT = _SMTP_USER


logging.basicConfig(level=logging.INFO)


def run_shell_cmd(cmd: list[str], cwd: Path | None = None) -> CompletedProcess:
    cmd_str = " ".join(cmd)
    logging.debug(f"Running: {cmd_str} (cwd={cwd})")

    result = subprocess.run(
        args=cmd,
        capture_output=True,
        text=True,
        cwd=cwd,
    )
    if result.returncode != 0:
        raise Exception(f"Command failed: {cmd_str}\n{result.stderr}")

    return result


def run_and_log(run_fn: Callable[[], None], errors: list[str]) -> None:
    try:
        run_fn()
    except Exception as e:
        logging.error(str(e))
        errors.append(f"FAILED: {e}")


def notify(errors: list[str]) -> None:
    hostname = socket.gethostname()
    result = "FAILED" if errors else "PASSED"
    subject = f"[Homelab] Backup tests {result}"
    body_lines = [
        "Context:",
        f"- Hostname: {hostname}",
        f"- Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        f"- Script: {sys.argv[0]}",
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

    smtp_password_file = os.environ.get("SMTP_PASSWORD_FILE")
    if not smtp_password_file:
        error = "SMTP_PASSWORD_FILE environment variable is not set."
        logging.error(error)
        raise Exception(error)
    with open(smtp_password_file, "r") as f:
        smtp_password = f.read()

    try:
        with smtplib.SMTP_SSL(_SMTP_SERVER, _SMTP_PORT) as smtp:
            smtp.login(_SMTP_USER, smtp_password)
            smtp.send_message(msg)
        logging.info("Email sent to %s", _EMAIL_RECIPIENT)
    except Exception as e:
        logging.error("Failed to send email: %s", e)
