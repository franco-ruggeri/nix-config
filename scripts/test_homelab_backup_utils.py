import logging
import smtplib
import subprocess
import socket
import os
from typing import Callable
from subprocess import CompletedProcess
from datetime import datetime, timedelta
from email.message import EmailMessage


_SMTP_SERVER = "smtp.gmail.com"
_SMTP_PORT = 465
_SMTP_USER = "franco.ruggeri.pro@gmail.com"
_EMAIL_RECIPIENT = _SMTP_USER
MAX_AGE_HOURS = timedelta(hours=25)


class BackupTestError(Exception):
    pass


def run(cmd: list[str], env: dict | None = None) -> CompletedProcess:
    cmd_str = " ".join(cmd)
    logging.debug(f"Running: {cmd_str}")

    result = subprocess.run(
        args=cmd,
        capture_output=True,
        text=True,
        env=env,
    )
    if result.returncode != 0:
        raise BackupTestError(f"Command failed: {cmd_str}\n{result.stderr}")

    return result


def test(test_fn: Callable[[], None], errors: list[str]) -> None:
    try:
        test_fn()
    except Exception as e:
        logging.error(str(e))
        errors.append(f"FAILED: {e}")


def notify(errors: list[str]) -> None:
    hostname = socket.gethostname()
    result = "FAILED" if errors else "PASSED"
    subject = f"[{hostname}] Backup tests {result}"
    body_lines = [
        f"Backup tests {result} on {hostname} at {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        "",
        *[f"  - {e}" for e in errors],
    ]
    body = "\n".join(body_lines)

    msg = EmailMessage()
    msg["Subject"] = subject
    msg["From"] = _SMTP_USER
    msg["To"] = _EMAIL_RECIPIENT
    msg.set_content(body)

    smtp_password_file = os.environ.get("SMTP_PASSWORD_FILE")
    assert smtp_password_file is not None
    with open(smtp_password_file, "r") as f:
        smtp_password = f.read()

    try:
        with smtplib.SMTP_SSL(_SMTP_SERVER, _SMTP_PORT) as smtp:
            smtp.login(_SMTP_USER, smtp_password)
            smtp.send_message(msg)
        logging.info("Email sent to %s", _EMAIL_RECIPIENT)
    except Exception as e:
        logging.error("Failed to send email: %s", e)


# def age_hours(timestamp_str: str) -> float:
#     """Return the age in hours of an ISO 8601 timestamp string."""
#     # Handle timestamps with or without timezone info
#     dt = datetime.fromisoformat(timestamp_str.replace("Z", "+00:00"))
#     if dt.tzinfo is None:
#         dt = dt.replace(tzinfo=timezone.utc)
#     now = datetime.now(timezone.utc)
#     return (now - dt).total_seconds() / 3600
