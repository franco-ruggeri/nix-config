#!/usr/bin/env python3

import json
import logging
from datetime import datetime

from homelab_backup_utils import (
    MAX_AGE_HOURS,
    notify,
    run_shell_cmd,
    run_and_log,
)

LONGHORN_STORAGE_CLASS = "longhorn"


def test_longhorn_backups() -> None:
    result = run_shell_cmd(["kubectl", "get", "pv", "-o", "json"])
    data = json.loads(result.stdout)
    persistent_volumes: set[str] = set()
    for pv in data.get("items"):
        if pv["spec"]["storageClassName"] != LONGHORN_STORAGE_CLASS:
            continue
        persistent_volumes.add(pv["metadata"]["name"])
    if not persistent_volumes:
        raise Exception("Longhorn: No Longhorn PVs found.")
    for pv in persistent_volumes:
        logging.info(f"Longhorn: Found PV {pv} using Longhorn storage class.")

    result = run_shell_cmd(
        [
            "kubectl",
            "get",
            "backups.longhorn.io",
            "-A",
            "-o",
            "json",
        ]
    )
    data = json.loads(result.stdout)
    pv_to_dt: dict[str, datetime] = {}
    for backup in data["items"]:
        pv = backup["metadata"]["labels"]["backup-volume"]
        state = backup["status"]["state"]
        if state != "Completed":
            continue
        dt = datetime.strptime(
            backup["status"]["snapshotCreatedAt"],
            "%Y-%m-%dT%H:%M:%SZ",
        )
        if pv in persistent_volumes and (pv not in pv_to_dt or dt > pv_to_dt[pv]):
            pv_to_dt[pv] = dt
    for pv, dt in pv_to_dt.items():
        logging.info(f"Longhorn: Found backup for PV {pv} created at {dt}.")

    if set(pv_to_dt.keys()) != persistent_volumes:
        raise Exception("Longhorn: Some PVs have no backups.")
    if any(datetime.now() - dt > MAX_AGE_HOURS for dt in pv_to_dt.values()):
        raise Exception("Longhorn: Some backups are too old.")
    logging.info("Longhorn: All backups are recent enough.")


def main() -> None:
    errors: list[str] = []
    run_and_log(run_fn=test_longhorn_backups, errors=errors)
    notify(errors)


if __name__ == "__main__":
    main()
