import logging
import subprocess
from abc import ABC, abstractmethod
from pathlib import Path
from subprocess import CompletedProcess


class Runner(ABC):
    @staticmethod
    def _run_cmd(
        cmd: list[str],
        capture_output: bool = False,
        cwd: Path | None = None,
    ) -> CompletedProcess[str]:
        cmd_str = " ".join(cmd)
        logging.debug(f"Running: {cmd_str} (cwd={cwd})")
        result = subprocess.run(args=cmd, capture_output=capture_output, text=True, cwd=cwd)
        if result.returncode != 0:
            raise Exception(f"Command failed: {cmd_str}\n{result.stderr}")
        return result

    @abstractmethod
    def build(self, cmd: list[str]) -> list[str]:
        raise NotImplementedError

    @abstractmethod
    def run(
        self,
        cmd: list[str],
        capture_output: bool = False,
        cwd: Path | None = None,
    ) -> CompletedProcess[str]:
        raise NotImplementedError
