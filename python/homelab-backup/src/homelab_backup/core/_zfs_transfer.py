import re
import subprocess
from abc import ABC, abstractmethod

from homelab_backup.core._zfs_dataset import ZfsDataset


class ZfsTransfer(ABC):
    def __init__(self, src: ZfsDataset) -> None:
        if not src.is_remote:
            raise ValueError(f"ZfsTransfer src must be a remote dataset, got local: {src.name}")
        self._src = src
        self._hostname = self._get_hostname()

    @staticmethod
    def _get_hostname() -> str:
        raw_hostname = subprocess.run(["hostname", "-s"], capture_output=True, text=True).stdout.strip()
        if not raw_hostname:
            raise Exception("Could not determine local hostname for snapshot prefix.")
        prefix = re.sub(r"[^a-zA-Z0-9:_\-\.]", "-", raw_hostname)
        if not prefix:
            raise Exception("Resolved snapshot prefix is empty.")
        return prefix

    @abstractmethod
    def transfer(self) -> None:
        raise NotImplementedError
