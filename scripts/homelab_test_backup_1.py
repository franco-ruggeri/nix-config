#!/usr/bin/env python3

import json
import logging
from datetime import datetime

from homelab_test_backup_utils import MAX_AGE_HOURS, BackupTestError, notify, run, test

ZFS_DATASETS = {"zfs/k8s-nfs", "zfs/k8s-longhorn"}
LONGHORN_STORAGE_CLASS = "longhorn"
LONGHORN_NAMESPACE = "longhorn"

logging.basicConfig(level=logging.INFO)


def test_zfs_snapshots() -> None:
    result = run(
        [
            "zfs",
            "list",
            "-t",
            "snapshot",
            "-o",
            "name,creation",
        ]
    )

    dataset_to_snapshot_time: dict[str, datetime] = {}
    for line in result.stdout.splitlines()[1:]:
        parts = line.split(maxsplit=1)
        if len(parts) != 2:
            continue
        name = parts[0]
        time = datetime.strptime(parts[1].strip(), "%a %b %d %H:%M %Y")
        dataset = name.split("@")[0]
        if (
            dataset not in dataset_to_snapshot_time
            or time > dataset_to_snapshot_time[dataset]
        ):
            dataset_to_snapshot_time[dataset] = time
    for dataset, time in dataset_to_snapshot_time.items():
        logging.info(f"ZFS: Found snapshot for {dataset} created at {time}.")

    if set(dataset_to_snapshot_time.keys()) != ZFS_DATASETS:
        raise BackupTestError("ZFS: Not all the ZFS datasets have snapshosts.")
    logging.info("ZFS: Found snapshots for all the ZFS datasets.")

    if any(
        datetime.now() - dt > MAX_AGE_HOURS for dt in dataset_to_snapshot_time.values()
    ):
        raise BackupTestError("ZFS: Some ZFS snapshots are too old.")
    logging.info("ZFS: All ZFS snapshots are recent enough.")


def test_longhorn_backups() -> None:
    result = run(["kubectl", "get", "pv", "-o", "json"])
    data = json.loads(result.stdout)
    pv_to_pvc: dict[str, str] = {}
    for pv in data.get("items"):
        if pv["spec"]["storageClassName"] != LONGHORN_STORAGE_CLASS:
            continue
        pvc_ref = pv["spec"]["claimRef"]
        pvc = f"{pvc_ref['namespace']}/{pvc_ref['name']}"
        pv_to_pvc[pv["metadata"]["name"]] = pvc
    if not pv_to_pvc:
        raise BackupTestError("Longhorn: No Longhorn PVs found.")

    result = run(
        [
            "kubectl",
            "get",
            "backups.longhorn.io",
            "-n",
            LONGHORN_NAMESPACE,
            "-o",
            "json",
        ]
    )
    data = json.loads(result.stdout)
    pv_to_backup_time: dict[str, datetime] = {}
    for backup in data["items"]:
        pv = backup["metadata"]["labels"]["backup-volume"]
        state = backup["status"]["state"]
        if state != "Completed":
            continue
        time = datetime.strptime(
            backup["status"]["snapshotCreatedAt"],
            "%Y-%m-%dT%H:%M:%SZ",
        )
        if pv not in pv_to_backup_time or time > pv_to_backup_time[pv]:
            pv_to_backup_time[pv] = time
    for pv, time in pv_to_backup_time.items():
        logging.info(f"Longhorn: Found backup for PV {pv} created at {time}.")

    if set(pv_to_backup_time.keys()) != pv_to_pvc.keys():
        raise BackupTestError("Longhorn: Not all the PVs have backups.")
    logging.info("Longhorn: Found backups for all the PVs.")

    if any(datetime.now() - dt > MAX_AGE_HOURS for dt in pv_to_backup_time.values()):
        raise BackupTestError("Longhorn: Some Longhorn backups are too old.")
    logging.info("Longhorn: All Longhorn backups are recent enough.")


def main() -> None:
    errors: list[str] = []
    test(test_zfs_snapshots, errors)
    test(test_longhorn_backups, errors)
    notify(errors)


if __name__ == "__main__":
    main()
