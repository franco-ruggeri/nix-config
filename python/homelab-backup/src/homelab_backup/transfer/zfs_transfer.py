from abc import ABC, abstractmethod

from homelab_backup.utils import get_snapshot_prefix


class ZfsTransfer(ABC):
    def __init__(self) -> None:
        self._prefix = get_snapshot_prefix()

    @abstractmethod
    def transfer(self) -> None:
        raise NotImplementedError
