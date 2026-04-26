import logging
import os
import smtplib
import socket
import sys
from datetime import datetime
from email.message import EmailMessage
from pathlib import Path

_SMTP_SERVER = "smtp.gmail.com"
_SMTP_PORT = 465
_SMTP_USER = "franco.ruggeri.pro@gmail.com"
_EMAIL_RECIPIENT = _SMTP_USER


class Notifier:
    def notify(self, errors: list[str]) -> None:
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
