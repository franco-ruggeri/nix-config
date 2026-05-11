import logging
import subprocess

from homelab_backup.core._zfs_dataset import ZfsDataset
from homelab_backup.core._zfs_transfer import ZfsTransfer


class ZfsNativeTransfer(ZfsTransfer):
    def __init__(self, src: ZfsDataset, dst: ZfsDataset) -> None:
        super().__init__(src=src)
        if dst.is_remote:
            raise ValueError(f"ZfsNativeTransfer dst must be a local dataset, got remote: {dst.name}")
        self._dst = dst

    def transfer(self) -> None:
        try:
            logging.info("ZFS: Starting ZFS native transfer for %s", self._src.name)

            last_name = f"{self._hostname}-last"
            current_name = f"{self._hostname}-current"

            result = self._dst.runner.run(
                cmd=["zfs", "get", "-H", "-o", "value", "receive_resume_token", self._dst.name],
                capture_output=True,
            )
            resume_token = result.stdout.strip()
            is_resuming = resume_token not in ("", "-", "none")

            if is_resuming:
                logging.info("ZFS: Resuming interrupted transfer for %s", self._src.name)
                send_cmd = ["zfs", "send", "-t", resume_token]
            else:
                self._src.create_snapshot(current_name)

                src_last = self._src.snapshot_ref(last_name)
                src_current = self._src.snapshot_ref(current_name)
                has_src_last = self._src.has_snapshot(last_name)
                has_dst_last = self._dst.has_snapshot(last_name)
                use_incremental = has_src_last and has_dst_last

                send_cmd = ["zfs", "send"]
                if use_incremental:
                    send_cmd += ["-i", src_last]
                    logging.info(
                        "ZFS: Running incremental replication for %s from %s to %s",
                        self._src.name,
                        src_last,
                        src_current,
                    )
                else:
                    logging.info("ZFS: Running full replication for %s", src_current)
                send_cmd += [src_current]

            send_proc = subprocess.Popen(
                args=self._src.runner.build(send_cmd),
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            recv_proc = subprocess.Popen(
                args=self._dst.runner.build(["zfs", "receive", "-F", "-s", self._dst.name]),
                stdin=send_proc.stdout,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            if send_proc.stdout:
                send_proc.stdout.close()

            recv_stdout, recv_stderr = recv_proc.communicate()
            send_proc.wait()

            if recv_proc.returncode != 0:
                raise Exception(f"ZFS: Receive failed:\n{recv_stderr.decode(errors='replace')}")
            if not self._dst.has_snapshot(current_name):
                raise Exception(f"ZFS: Receive succeeded but snapshot {current_name} not found")
            if recv_stdout:
                logging.info(recv_stdout.decode(errors="replace").strip())

            for dataset in [self._src, self._dst]:
                dataset.destroy_snapshot(last_name)
                dataset.rename_snapshot(current_name, last_name)

            logging.info("ZFS: Native transfer completed successfully for %s", self._src.name)
        except Exception as e:
            logging.error("%s", e)
            raise
