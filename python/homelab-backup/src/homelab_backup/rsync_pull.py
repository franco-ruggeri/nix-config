import shlex
from pathlib import Path

from .utils import (
    build_ssh_cmd,
    get_env,
    get_snapshot_prefix,
    notify,
    remote_snapshot_exists,
    run_and_log,
    run_remote_cmd,
    run_shell_cmd,
)


def _get_remote_mountpoint(source_dataset: str) -> str:
    source_host = get_env("SOURCE_HOST")
    source_user = get_env("SOURCE_USER")
    result = run_shell_cmd(
        build_ssh_cmd()
        + [
            f"{source_user}@{source_host}",
            "zfs",
            "get",
            "-H",
            "-o",
            "value",
            "mountpoint",
            source_dataset,
        ]
    )
    mountpoint = result.stdout.strip()
    if not mountpoint:
        raise Exception(f"Could not resolve mountpoint for dataset {source_dataset}.")
    return mountpoint


def _rsync_pull() -> None:
    source_dataset = get_env("SOURCE_DATASET")
    source_host = get_env("SOURCE_HOST")
    source_user = get_env("SOURCE_USER")
    rsync_dest_path = Path(get_env("RSYNC_DEST_PATH")).expanduser()

    snapshot_prefix = get_snapshot_prefix()
    snapshot_name = f"{snapshot_prefix}-current"
    snapshot = f"{source_dataset}@{snapshot_name}"

    if remote_snapshot_exists(
        source_host=source_host,
        source_user=source_user,
        dataset=source_dataset,
        snapshot_name=snapshot_name,
    ):
        run_remote_cmd(source_host=source_host, source_user=source_user, remote_cmd=["zfs", "destroy", snapshot])

    run_remote_cmd(source_host=source_host, source_user=source_user, remote_cmd=["zfs", "snapshot", snapshot])

    try:
        remote_mountpoint = _get_remote_mountpoint(source_dataset)
        remote_snapshot_path = f"{remote_mountpoint}/.zfs/snapshot/{snapshot_name}/"

        run_shell_cmd(["mkdir", "-p", str(rsync_dest_path)])

        ssh_transport = " ".join(shlex.quote(part) for part in build_ssh_cmd())
        run_shell_cmd(
            [
                "rsync",
                "-a",
                "--delete",
                "-e",
                ssh_transport,
                f"{source_user}@{source_host}:{remote_snapshot_path}",
                f"{rsync_dest_path}/",
            ]
        )
    finally:
        if remote_snapshot_exists(
            source_host=source_host,
            source_user=source_user,
            dataset=source_dataset,
            snapshot_name=snapshot_name,
        ):
            run_remote_cmd(source_host=source_host, source_user=source_user, remote_cmd=["zfs", "destroy", snapshot])


def main() -> None:
    errors: list[str] = []
    run_and_log(run_fn=_rsync_pull, errors=errors)
    notify(errors)
