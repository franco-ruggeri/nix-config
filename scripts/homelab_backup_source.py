#!/usr/bin/env python3

import json
import logging
from datetime import datetime

from homelab_backup_utils import (
    MAX_AGE_HOURS,
    ZFS_DATASETS,
    notify,
    run_shell_cmd,
    run_and_log,
)

LONGHORN_STORAGE_CLASS = "longhorn"


def chmod_zfs() -> None:
    for zfs_dataset in ZFS_DATASETS:
        run_shell_cmd(
            [
                "chmod",
                "-R",
                "755",
                f"/mnt/zfs/{zfs_dataset}",
            ]
        )


def test_zfs_snapshots() -> None:
    result = run_shell_cmd(
        [
            "zfs",
            "list",
            "-t",
            "snapshot",
            "-o",
            "name,creation",
        ]
    )

    dataset_to_dt: dict[str, datetime] = {}
    for line in result.stdout.splitlines()[1:]:
        parts = line.split(maxsplit=1)
        if len(parts) != 2:
            continue
        name = parts[0]
        dt = datetime.strptime(parts[1].strip(), "%a %b %d %H:%M %Y")
        dataset = name.split("@")[0]
        if dataset not in dataset_to_dt or dt > dataset_to_dt[dataset]:
            dataset_to_dt[dataset] = dt
    for dataset, dt in dataset_to_dt.items():
        logging.info(f"ZFS: Found snapshot for {dataset} created at {dt}.")

    if set(dataset_to_dt.keys()) != ZFS_DATASETS:
        raise Exception("ZFS: Not all the ZFS datasets have snapshosts.")
    logging.info("ZFS: Found snapshots for all the ZFS datasets.")

    if any(datetime.now() - dt > MAX_AGE_HOURS for dt in dataset_to_dt.values()):
        raise Exception("ZFS: Some ZFS snapshots are too old.")
    logging.info("ZFS: All ZFS snapshots are recent enough.")


def test_longhorn_backups() -> None:
    result = run_shell_cmd(["kubectl", "get", "pv", "-o", "json"])
    data = json.loads(result.stdout)
    pv_to_pvc: dict[str, str] = {}
    for pv in data.get("items"):
        if pv["spec"]["storageClassName"] != LONGHORN_STORAGE_CLASS:
            continue
        pvc_ref = pv["spec"]["claimRef"]
        pvc = f"{pvc_ref['namespace']}/{pvc_ref['name']}"
        pv_to_pvc[pv["metadata"]["name"]] = pvc
    if not pv_to_pvc:
        raise Exception("Longhorn: No Longhorn PVs found.")

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
        if pv not in pv_to_dt or dt > pv_to_dt[pv]:
            pv_to_dt[pv] = dt
    for pv, dt in pv_to_dt.items():
        logging.info(f"Longhorn: Found backup for PV {pv} created at {dt}.")

    if set(pv_to_dt.keys()) != pv_to_pvc.keys():
        raise Exception("Longhorn: Not all the PVs have backups.")
    logging.info("Longhorn: Found backups for all the PVs.")

    if any(datetime.now() - dt > MAX_AGE_HOURS for dt in pv_to_dt.values()):
        raise Exception("Longhorn: Some Longhorn backups are too old.")
    logging.info("Longhorn: All Longhorn backups are recent enough.")


def main() -> None:
    errors: list[str] = []
    run_and_log(run_fn=chmod_zfs, errors=errors)
    run_and_log(run_fn=test_zfs_snapshots, errors=errors)
    run_and_log(run_fn=test_longhorn_backups, errors=errors)
    notify(errors)
