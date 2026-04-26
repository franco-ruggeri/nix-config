import logging
import subprocess

from .utils import (
    build_ssh_cmd,
    get_env,
    get_snapshot_prefix,
    notify,
    remote_snapshot_exists,
    run_and_log,
    run_ssh_cmd,
    run_shell_cmd,
)

_BACKUP_DATASETS = [
    "zfs/k8s-nfs-backup",
    "zfs/k8s-longhorn-backup",
]


def snapshot_exists(dataset: str, snapshot_name: str) -> bool:
    snapshot = f"{dataset}@{snapshot_name}"
    try:
        run_shell_cmd(
            [
                "zfs",
                "list",
                "-H",
                "-t",
                "snapshot",
                "-o",
                "name",
                snapshot,
            ],
            capture_output=True,
        )
        return True
    except Exception:
        return False


def _pull_latest_snapshot_for_dataset(source_dataset: str) -> None:
    source_host = get_env("SOURCE_HOST")
    source_user = get_env("SOURCE_USER")
    dest_dataset = source_dataset

    prefix = get_snapshot_prefix()
    last_name = f"{prefix}-last"
    current_name = f"{prefix}-current"

    source_last = f"{source_dataset}@{last_name}"
    source_current = f"{source_dataset}@{current_name}"
    dest_last = f"{dest_dataset}@{last_name}"
    dest_current = f"{dest_dataset}@{current_name}"

    logging.info("Using snapshot prefix for %s: %s", source_dataset, prefix)

    if remote_snapshot_exists(
        source_host=source_host,
        source_user=source_user,
        dataset=source_dataset,
        snapshot_name=current_name,
    ):
        logging.info("Destroying stale source snapshot %s", source_current)
        run_ssh_cmd(source_host=source_host, source_user=source_user, remote_cmd=["zfs", "destroy", source_current])

    logging.info("Creating source snapshot %s", source_current)
    run_ssh_cmd(source_host=source_host, source_user=source_user, remote_cmd=["zfs", "snapshot", source_current])

    has_source_last = remote_snapshot_exists(
        source_host=source_host,
        source_user=source_user,
        dataset=source_dataset,
        snapshot_name=last_name,
    )
    has_dest_last = snapshot_exists(dest_dataset, last_name)
    use_incremental = has_source_last and has_dest_last

    send_cmd = ["zfs", "send"]
    if use_incremental:
        send_cmd += ["-I", source_last]
        logging.info("Running incremental replication for %s from %s to %s", source_dataset, source_last, source_current)
    else:
        logging.info("Running full replication for %s", source_current)
    send_cmd += [source_current]

    send_proc = subprocess.Popen(
        build_ssh_cmd() + [f"{source_user}@{source_host}"] + send_cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    recv_proc = subprocess.Popen(
        ["zfs", "receive", "-F", dest_dataset],
        stdin=send_proc.stdout,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if send_proc.stdout:
        send_proc.stdout.close()

    recv_stdout, recv_stderr = recv_proc.communicate()
    send_stderr = send_proc.stderr.read() if send_proc.stderr else b""
    send_rc = send_proc.wait()

    if send_rc != 0:
        raise Exception(f"zfs send failed:\n{send_stderr.decode(errors='replace')}")
    if recv_proc.returncode != 0:
        raise Exception(f"zfs receive failed:\n{recv_stderr.decode(errors='replace')}")
    if recv_stdout:
        logging.info(recv_stdout.decode(errors="replace").strip())

    if snapshot_exists(dest_dataset, last_name):
        logging.info("Destroying destination snapshot %s", dest_last)
        run_shell_cmd(["zfs", "destroy", dest_last])
    logging.info("Renaming destination snapshot %s -> %s", dest_current, dest_last)
    run_shell_cmd(["zfs", "rename", dest_current, dest_last])

    if remote_snapshot_exists(
        source_host=source_host,
        source_user=source_user,
        dataset=source_dataset,
        snapshot_name=last_name,
    ):
        logging.info("Destroying source snapshot %s", source_last)
        run_ssh_cmd(source_host=source_host, source_user=source_user, remote_cmd=["zfs", "destroy", source_last])
    logging.info("Renaming source snapshot %s -> %s", source_current, source_last)
    run_ssh_cmd(source_host=source_host, source_user=source_user, remote_cmd=["zfs", "rename", source_current, source_last])


def pull_latest_snapshot() -> None:
    for backup_dataset in _BACKUP_DATASETS:
        _pull_latest_snapshot_for_dataset(backup_dataset)


def main() -> None:
    errors: list[str] = []
    run_and_log(run_fn=pull_latest_snapshot, errors=errors)
    notify(errors)
