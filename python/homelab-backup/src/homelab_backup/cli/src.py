from datetime import datetime
from pathlib import Path

from homelab_backup.backup.dataset_backup import DatasetBackup
from homelab_backup.backup.restic_repository import ResticRepository
from homelab_backup.backup.src_backup_orchestrator import SrcBackupOrchestrator
from homelab_backup.datasets.zfs_dataset import ZfsDataset
from homelab_backup.execution.local_runner import LocalRunner
from homelab_backup.utils import (
    MAX_AGE_HOURS,
    notify,
    run_and_log,
)

_ZFS_ROOT = Path("/mnt")
_RESTIC_REPOSITORY = _ZFS_ROOT / "zfs" / "k8s-backup"
_ZFS_DATASETS = [
    "zfs/k8s-nfs",
    "zfs/k8s-longhorn",
]


def _build_dataset_backups() -> list[DatasetBackup]:
    local_runner = LocalRunner()
    repository = ResticRepository(path=_RESTIC_REPOSITORY)
    return [
        DatasetBackup(
            dataset=ZfsDataset(name=zfs_dataset, runner=local_runner),
            repository=repository,
        )
        for zfs_dataset in _ZFS_DATASETS
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
