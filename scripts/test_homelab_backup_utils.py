import logging
import smtplib
import subprocess
import socket
import os
from typing import Callable
from subprocess import CompletedProcess
from datetime import datetime, timedelta
from email.message import EmailMessage


SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 465
SMTP_USER = "franco.ruggeri.pro@gmail.com"
ALERT_EMAIL = SMTP_USER
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


def alert(errors: list[str]) -> None:
    hostname = socket.gethostname()
    subject = f"[{hostname}] Backup tests FAILED"
    body_lines = [
        f"Backup check FAILED on {hostname} at {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        "",
        *[f"  - {e}" for e in errors],
    ]
    body = "\n".join(body_lines)

    msg = EmailMessage()
    msg["Subject"] = subject
    msg["From"] = SMTP_USER
    msg["To"] = ALERT_EMAIL
    msg.set_content(body)

    smtp_password = os.environ.get("SMTP_PASSWORD")
    assert smtp_password is not None

    try:
        with smtplib.SMTP_SSL(SMTP_SERVER, SMTP_PORT) as smtp:
            smtp.login(SMTP_USER, smtp_password)
            smtp.send_message(msg)
        logging.info("Alert email sent to %s", ALERT_EMAIL)
    except Exception as e:
        logging.error("Failed to send alert email: %s", e)


# def age_hours(timestamp_str: str) -> float:
#     """Return the age in hours of an ISO 8601 timestamp string."""
#     # Handle timestamps with or without timezone info
#     dt = datetime.fromisoformat(timestamp_str.replace("Z", "+00:00"))
#     if dt.tzinfo is None:
#         dt = dt.replace(tzinfo=timezone.utc)
#     now = datetime.now(timezone.utc)
#     return (now - dt).total_seconds() / 3600
