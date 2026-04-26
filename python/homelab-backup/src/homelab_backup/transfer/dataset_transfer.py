from abc import ABC, abstractmethod


class DatasetTransfer(ABC):
    @abstractmethod
    def transfer(self, snapshot_prefix: str) -> None:
        raise NotImplementedError
