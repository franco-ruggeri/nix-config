#!/usr/bin/env python3

import logging
import os

from homelab_test_backup_utils import (
    MAX_AGE_HOURS,
    run,
    test,
    notify,
)

NFS_MOUNT = "/mnt/nfs/k8s-backup"
RESTIC_REPOS = [
    "/mnt/zfs/k8s-backup",
    "/home/franco/drives/onedrive",
]
RESTIC_SYSTEMD_SERVICE = "restic@backup.service"


def test_nfs_mount() -> None:
    proc = run(["mountpoint", "-q", NFS_MOUNT])
    if proc.returncode != 0:
        errors.append(f"NFS: {NFS_MOUNT} is not mounted")
        return

    try:
        entries = os.listdir(NFS_MOUNT)
    except OSError as e:
        errors.append(f"NFS: Could not list {NFS_MOUNT}: {e}")
        return

    if not entries:
        errors.append(f"NFS: {NFS_MOUNT} is mounted but empty")
    else:
        logging.info(
            "OK: NFS mount %s is alive and non-empty (%d entries)",
            NFS_MOUNT,
            len(entries),
        )


def test_restic_snapshots() -> None:
    for repo in RESTIC_REPOS:
        if not os.path.exists(repo):
            errors.append(f"Restic: Repository path '{repo}' does not exist")
            continue

        data = run_json(["restic", "-r", repo, "snapshots", "--json", "--last"])
        if data is None:
            errors.append(f"Restic: Failed to query snapshots in '{repo}'")
            continue

        if not data:
            errors.append(f"Restic: No snapshots found in '{repo}'")
            continue

        # --last returns one snapshot per unique (host, paths) combo; find the newest overall
        newest = min(data, key=lambda s: age_hours(s["time"]))
        age = age_hours(newest["time"])

        if age > MAX_AGE_HOURS:
            errors.append(
                f"Restic: Latest snapshot in '{repo}' is {age:.1f}h old (max {MAX_AGE_HOURS}h)"
            )
        else:
            logging.info("OK: Restic snapshot in '%s' is %.1fh old", repo, age)


def test_restic_logs() -> None:
    # Check for error-level journal entries in the last 26h
    proc = run(
        [
            "journalctl",
            "-u",
            RESTIC_SYSTEMD_SERVICE,
            "--since",
            "26 hours ago",
            "-p",
            "err",
            "--no-pager",
            "-q",
        ]
    )
    if proc.returncode not in (0, 1):
        errors.append(f"Restic: journalctl failed: {proc.stderr.strip()}")
    elif proc.stdout.strip():
        errors.append(
            f"Restic: Errors in systemd journal for {RESTIC_SYSTEMD_SERVICE}:\n"
            + proc.stdout.strip()
        )
    else:
        logging.info("OK: No errors in systemd journal for %s", RESTIC_SYSTEMD_SERVICE)

    # Check last exit code
    proc2 = run(
        [
            "systemctl",
            "show",
            RESTIC_SYSTEMD_SERVICE,
            "--property=ExecMainStatus",
            "--value",
        ]
    )
    if proc2.returncode != 0:
        errors.append(f"Restic: systemctl show failed: {proc2.stderr.strip()}")
        return

    exit_code = proc2.stdout.strip()
    if exit_code and exit_code != "0":
        errors.append(
            f"Restic: {RESTIC_SYSTEMD_SERVICE} last exited with code {exit_code}"
        )
    else:
        logging.info(
            "OK: %s last exit code: %s", RESTIC_SYSTEMD_SERVICE, exit_code or "unknown"
        )


def main() -> None:
    errors: list[str] = []
    test(test_nfs_mount, errors)
    test(test_restic_snapshots, errors)
    test(test_restic_logs, errors)
    notify(errors)


if __name__ == "__main__":
    main()
