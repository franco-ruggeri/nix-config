from pathlib import Path
from subprocess import CompletedProcess

from homelab_backup.execution.command_runner import CommandRunner
from homelab_backup.utils import run_shell_cmd


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
