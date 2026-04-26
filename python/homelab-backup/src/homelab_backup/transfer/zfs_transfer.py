from abc import ABC, abstractmethod


class ZfsTransfer(ABC):
    @abstractmethod
    def transfer(self) -> None:
        raise NotImplementedError
