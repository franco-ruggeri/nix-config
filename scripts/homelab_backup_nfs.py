#!/usr/bin/env python3

import logging
from datetime import datetime

from homelab_backup_utils import (
    MAX_AGE_HOURS,
    ZFS_DATASETS,
    notify,
    run_shell_cmd,
    run_and_log,
)


def chmod_zfs_datasets() -> None:
    for zfs_dataset in ZFS_DATASETS:
        logging.info(f"ZFS: Setting permissions for {zfs_dataset} to 755...")
        run_shell_cmd(
            [
                "chmod",
                "-R",
                "755",
                f"/mnt/zfs/{zfs_dataset}",
            ]
        )
        logging.info(f"ZFS: Set permissions for {zfs_dataset} to 755.")


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

    datasets = {f"zfs/{dataset}" for dataset in ZFS_DATASETS}
    if set(dataset_to_dt.keys()) != datasets:
        raise Exception("ZFS: Not all the ZFS datasets have snapshosts.")
    logging.info("ZFS: Found snapshots for all the ZFS datasets.")

    if any(datetime.now() - dt > MAX_AGE_HOURS for dt in dataset_to_dt.values()):
        raise Exception("ZFS: Some ZFS snapshots are too old.")
    logging.info("ZFS: All ZFS snapshots are recent enough.")


def main() -> None:
    errors: list[str] = []
    run_and_log(run_fn=chmod_zfs_datasets, errors=errors)
    run_and_log(run_fn=test_zfs_snapshots, errors=errors)
    notify(errors)


if __name__ == "__main__":
    main()
