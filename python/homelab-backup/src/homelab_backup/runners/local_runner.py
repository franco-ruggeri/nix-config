from pathlib import Path
from subprocess import CompletedProcess

from homelab_backup.runners.runner import Runner


class LocalRunner(Runner):
    def build(self, cmd: list[str]) -> list[str]:
        return cmd

    def run(
        self,
        cmd: list[str],
        capture_output: bool = False,
        cwd: Path | None = None,
    ) -> CompletedProcess[str]:
        return self._run_cmd(cmd, capture_output=capture_output, cwd=cwd)
