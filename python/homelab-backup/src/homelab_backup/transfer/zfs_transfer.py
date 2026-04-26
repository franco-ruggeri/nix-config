from abc import ABC, abstractmethod

from homelab_backup.utils import get_snapshot_prefix


class ZfsTransfer(ABC):
    def _snapshot_prefix(self) -> str:
        return get_snapshot_prefix()

    @abstractmethod
    def transfer(self) -> None:
        raise NotImplementedError
