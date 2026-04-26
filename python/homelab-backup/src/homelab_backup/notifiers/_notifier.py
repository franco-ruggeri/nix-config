from abc import ABC, abstractmethod


class Notifier(ABC):
    @abstractmethod
    def notify(self, error: Exception | None = None) -> None:
        raise NotImplementedError
