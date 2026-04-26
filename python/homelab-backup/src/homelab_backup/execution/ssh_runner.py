import shlex
from pathlib import Path
from subprocess import CompletedProcess

from homelab_backup.execution.command_runner import CommandRunner
from homelab_backup.utils import build_ssh_cmd, run_shell_cmd


class SshRunner(CommandRunner):
    def __init__(self, host: str, user: str) -> None:
        self._host = host
        self._user = user

    def build(self, cmd: list[str]) -> list[str]:
        return build_ssh_cmd() + [f"{self._user}@{self._host}"] + cmd

    def run(
        self,
        cmd: list[str],
        capture_output: bool = False,
        cwd: Path | None = None,
    ) -> CompletedProcess[str]:
        if cwd is not None:
            raise Exception("cwd is not supported for remote commands.")
        return run_shell_cmd(self.build(cmd), capture_output=capture_output)

    def ssh_transport(self) -> str:
        return " ".join(shlex.quote(part) for part in build_ssh_cmd())

    def remote(self, path: str | Path) -> str:
        return f"{self._user}@{self._host}:{path}"
