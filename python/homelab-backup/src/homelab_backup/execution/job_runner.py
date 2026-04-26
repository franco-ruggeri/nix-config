import logging
from typing import Callable


class JobRunner:
    def __init__(self) -> None:
        self._errors: list[str] = []

    def run(self, label: str, fn: Callable[[], None]) -> None:
        try:
            fn()
        except Exception as e:
            logging.error("[%s] %s", label, e)
            self._errors.append(f"FAILED [{label}]: {e}")

    @property
    def errors(self) -> list[str]:
        return list(self._errors)

    @property
    def succeeded(self) -> bool:
        return not self._errors
