import re
import subprocess
from abc import ABC, abstractmethod


class ZfsTransfer(ABC):
    def __init__(self) -> None:
        self._prefix = self._get_prefix()

    @staticmethod
    def _get_prefix() -> str:
        raw_hostname = subprocess.run(
            ["hostname", "-s"], capture_output=True, text=True
        ).stdout.strip()
        if not raw_hostname:
            raise Exception("Could not determine local hostname for snapshot prefix.")
        prefix = re.sub(r"[^a-zA-Z0-9:_\-\.]", "-", raw_hostname)
        if not prefix:
            raise Exception("Resolved snapshot prefix is empty.")
        return prefix

    @abstractmethod
    def transfer(self) -> None:
        raise NotImplementedError
