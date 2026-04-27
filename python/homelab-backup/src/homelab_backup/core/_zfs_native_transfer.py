import logging
import subprocess

from homelab_backup.core._zfs_dataset import ZfsDataset
from homelab_backup.core._zfs_transfer import ZfsTransfer


class ZfsNativeTransfer(ZfsTransfer):
    def __init__(self, source: ZfsDataset, destination: ZfsDataset) -> None:
        super().__init__(source=source)
        if destination.is_remote:
            raise ValueError(
                f"ZfsNativeTransfer destination must be a local dataset, got remote: {destination.name}"
            )
        self._destination = destination

    def transfer(self) -> None:
        logging.info("Starting ZFS replication for %s", self._source.name)
        try:
            self._do_transfer()
        except Exception as e:
            logging.error("%s", e)
            raise

    def _do_transfer(self) -> None:
        last_name = f"{self._prefix}-last"
        current_name = f"{self._prefix}-current"

        self._source.create_snapshot(current_name)

        source_last = self._source.snapshot_ref(last_name)
        source_current = self._source.snapshot_ref(current_name)
        has_source_last = self._source.snapshot_exists(last_name)
        has_dest_last = self._destination.snapshot_exists(last_name)
        use_incremental = has_source_last and has_dest_last

        send_cmd = ["zfs", "send"]
        if use_incremental:
            send_cmd += ["-I", source_last]
            logging.info(
                "Running incremental replication for %s from %s to %s",
                self._source.name,
                source_last,
                source_current,
            )
        else:
            logging.info("Running full replication for %s", source_current)
        send_cmd += [source_current]

        send_proc = subprocess.Popen(
            self._source.runner.build(send_cmd),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        recv_proc = subprocess.Popen(
            self._destination.runner.build(["zfs", "receive", "-F", self._destination.name]),
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

        self._destination.destroy_snapshot(last_name)
        self._destination.rename_snapshot(current_name, last_name)

        self._source.destroy_snapshot(last_name)
        self._source.rename_snapshot(current_name, last_name)
