from abc import ABC, abstractmethod


class ZfsTransfer(ABC):
    @abstractmethod
    def transfer(self, snapshot_prefix: str) -> None:
        raise NotImplementedError
