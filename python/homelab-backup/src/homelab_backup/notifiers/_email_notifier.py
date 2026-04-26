import logging
import os
import smtplib
import socket
import sys
from datetime import datetime
from email.message import EmailMessage
from pathlib import Path

from homelab_backup.notifiers._notifier import Notifier


class EmailNotifier(Notifier):
    _SMTP_SERVER = "smtp.gmail.com"
    _SMTP_PORT = 465
    _SMTP_USER = "franco.ruggeri.pro@gmail.com"
    _EMAIL_RECIPIENT = _SMTP_USER

    def __init__(self) -> None:
        with open(os.environ["SMTP_PASSWORD_FILE"], "r") as f:
            self._smtp_password = f.read()

    def notify(self, error: Exception | None = None) -> None:
        hostname = socket.gethostname()
        script = Path(sys.argv[0])
        result = "FAILED" if error else "PASSED"

        subject = f"[Homelab] {result} - {hostname}"
        body_lines = [
            "Context:",
            f"- Hostname: {hostname}",
            f"- Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            f"- Script: {script.name}",
            f"- Result: {result}",
        ]
        if error:
            body_lines += [
                "",
                "Error:",
                f"- {error}",
            ]
        body = "\n".join(body_lines)

        msg = EmailMessage()
        msg["Subject"] = subject
        msg["From"] = self._SMTP_USER
        msg["To"] = self._EMAIL_RECIPIENT
        msg.set_content(body)

        try:
            with smtplib.SMTP_SSL(self._SMTP_SERVER, self._SMTP_PORT) as smtp:
                smtp.login(self._SMTP_USER, self._smtp_password)
                smtp.send_message(msg)
            logging.info("Email sent to %s", self._EMAIL_RECIPIENT)
        except Exception as e:
            logging.error("Failed to send email: %s", e)
