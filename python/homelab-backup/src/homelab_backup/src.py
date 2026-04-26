from datetime import datetime
from pathlib import Path

from .dataset_backup import DatasetBackup
from .local_runner import LocalRunner
from .restic_repository import ResticRepository
from .src_backup_orchestrator import SrcBackupOrchestrator
from .zfs_dataset import ZfsDataset
from .utils import (
    MAX_AGE_HOURS,
    notify,
    run_and_log,
)

_ZFS_ROOT = Path("/mnt")
_RESTIC_REPOSITORIES = {
    "zfs/k8s-nfs": _ZFS_ROOT / "zfs" / "k8s-nfs-backup",
    "zfs/k8s-longhorn": _ZFS_ROOT / "zfs" / "k8s-longhorn-backup",
}


def _build_dataset_backups() -> list[DatasetBackup]:
    local_runner = LocalRunner()
    return [
        DatasetBackup(
            dataset=ZfsDataset(name=zfs_dataset, runner=local_runner),
            repository=ResticRepository(path=restic_repository),
        )
        for zfs_dataset, restic_repository in _RESTIC_REPOSITORIES.items()
    ]


def main() -> None:
    errors: list[str] = []
    now = datetime.now()
    orchestrator = SrcBackupOrchestrator(dataset_backups=_build_dataset_backups(), max_age=MAX_AGE_HOURS)

    run_and_log(run_fn=orchestrator.run_backup, errors=errors)
    run_and_log(run_fn=orchestrator.verify_snapshots, errors=errors)

    if now.weekday() == 0:
        run_and_log(run_fn=orchestrator.verify_metadata, errors=errors)

    if now.day == 1:
        run_and_log(run_fn=orchestrator.verify_data, errors=errors)

    notify(errors)
