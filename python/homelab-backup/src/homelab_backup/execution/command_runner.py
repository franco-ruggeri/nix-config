from abc import ABC, abstractmethod
from pathlib import Path
from subprocess import CompletedProcess


class CommandRunner(ABC):
    @abstractmethod
    def build_command(self, cmd: list[str]) -> list[str]:
        raise NotImplementedError

    @abstractmethod
    def run(
        self,
        cmd: list[str],
        capture_output: bool = False,
        cwd: Path | None = None,
    ) -> CompletedProcess[str]:
        raise NotImplementedError
