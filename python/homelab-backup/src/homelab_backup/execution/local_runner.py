from pathlib import Path
from subprocess import CompletedProcess

from ..utils import run_shell_cmd


from .command_runner import CommandRunner


class LocalRunner(CommandRunner):

    def build_command(self, cmd: list[str]) -> list[str]:
        return cmd

    def run(
        self,
        cmd: list[str],
        capture_output: bool = False,
        cwd: Path | None = None,
    ) -> CompletedProcess:
        return run_shell_cmd(cmd, capture_output=capture_output, cwd=cwd)
