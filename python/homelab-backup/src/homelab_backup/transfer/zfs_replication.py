import logging
import subprocess

from homelab_backup.datasets.zfs_dataset import ZfsDataset
from homelab_backup.transfer.dataset_transfer import DatasetTransfer


class ZfsReplication(DatasetTransfer):
    def __init__(self, source: ZfsDataset, destination: ZfsDataset) -> None:
        self.source = source
        self.destination = destination

    def replicate(self, prefix: str) -> None:
        last_name = f"{prefix}-last"
        current_name = f"{prefix}-current"

        if self.source.snapshot_exists(current_name):
            self.source.destroy_snapshot(current_name)
        self.source.create_snapshot(current_name)

        source_last = self.source.snapshot_ref(last_name)
        source_current = self.source.snapshot_ref(current_name)
        has_source_last = self.source.snapshot_exists(last_name)
        has_dest_last = self.destination.snapshot_exists(last_name)
        use_incremental = has_source_last and has_dest_last

        send_cmd = ["zfs", "send"]
        if use_incremental:
            send_cmd += ["-I", source_last]
            logging.info(
                "Running incremental replication for %s from %s to %s",
                self.source.name,
                source_last,
                source_current,
            )
        else:
            logging.info("Running full replication for %s", source_current)
        send_cmd += [source_current]

        send_proc = subprocess.Popen(
            self.source.runner.build_command(send_cmd),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        recv_proc = subprocess.Popen(
            self.destination.runner.build_command(["zfs", "receive", "-F", self.destination.name]),
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

        if self.destination.snapshot_exists(last_name):
            self.destination.destroy_snapshot(last_name)
        self.destination.rename_snapshot(current_name, last_name)

        if self.source.snapshot_exists(last_name):
            self.source.destroy_snapshot(last_name)
        self.source.rename_snapshot(current_name, last_name)

    def transfer(self, snapshot_prefix: str) -> None:
        self.replicate(snapshot_prefix)
