#!/usr/bin/env python3

import logging
from datetime import datetime
from test_homelab_backup_utils import run, MAX_AGE_HOURS, BackupTestError, notify, test

ZFS_DATASETS = {"zfs/k8s-nfs", "zfs/k8s-longhorn"}
KUBECONFIG = "/etc/rancher/k3s/k3s.yaml"
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

    dataset_to_latest: dict[str, datetime] = {}
    for line in result.stdout.splitlines()[1:]:
        parts = line.split(maxsplit=1)
        if len(parts) != 2:
            continue
        name = parts[0]
        creation = datetime.strptime(parts[1].strip(), "%a %b %d %H:%M %Y")
        dataset = name.split("@")[0]
        if dataset not in dataset_to_latest or creation > dataset_to_latest[dataset]:
            dataset_to_latest[dataset] = creation

    if set(dataset_to_latest.keys()) != ZFS_DATASETS:
        raise BackupTestError("Not all the ZFS datasets have snapshosts")
    logging.info("Found snapshots for all the ZFS datasets.")

    if any(datetime.now() - dt > MAX_AGE_HOURS for dt in dataset_to_latest.values()):
        raise BackupTestError("Some ZFS snapshots are too old")
    logging.info("All ZFS snapshots are recent enough.")


# def test_longhorn_backups(errors: list[str]) -> None:
#     env = {**os.environ, "KUBECONFIG": KUBECONFIG}
#
#     # Get all Longhorn PVs: pv_name -> "namespace/pvcname"
#     pv_data = run_json(["kubectl", "get", "pv", "-o", "json"], env=env)
#     if pv_data is None:
#         errors.append("Longhorn: 'kubectl get pv' failed")
#         return
#
#     pvs: dict[str, str] = {}
#     for pv in pv_data.get("items", []):
#         if pv["spec"].get("storageClassName") != LONGHORN_STORAGE_CLASS:
#             continue
#         ref = pv["spec"].get("claimRef", {})
#         pvs[pv["metadata"]["name"]] = (
#             f"{ref.get('namespace', '?')}/{ref.get('name', '?')}"
#         )
#
#     if not pvs:
#         errors.append("Longhorn: No PVs with storageClassName 'longhorn' found")
#         return
#
#     # Get all backups grouped by volume name
#     backup_data = run_json(
#         [
#             "kubectl",
#             "get",
#             "backups.longhorn.io",
#             "-n",
#             LONGHORN_NAMESPACE,
#             "-o",
#             "json",
#         ],
#         env=env,
#     )
#     if backup_data is None:
#         errors.append("Longhorn: 'kubectl get backups.longhorn.io' failed")
#         return
#
#     backups: dict[str, list[dict]] = {}
#     for b in backup_data.get("items", []):
#         volume = b["metadata"]["labels"].get("backup-volume", "")
#         if not volume:
#             continue
#         backups.setdefault(volume, []).append(
#             {
#                 "snapshotCreatedAt": b["status"].get("snapshotCreatedAt", ""),
#                 "state": b["status"].get("state", ""),
#             }
#         )
#
#     for pv_name, pvc_label in pvs.items():
#         pv_backups = backups.get(pv_name, [])
#
#         if not pv_backups:
#             errors.append(
#                 f"Longhorn: No backup found for PVC '{pvc_label}' (volume: {pv_name})"
#             )
#             continue
#
#         completed = [b for b in pv_backups if b["state"] == "Completed"]
#         if not completed:
#             states = {b["state"] for b in pv_backups}
#             errors.append(
#                 f"Longhorn: No completed backup for PVC '{pvc_label}' — states found: {', '.join(states)}"
#             )
#             continue
#
#         newest = min(completed, key=lambda b: age_hours(b["snapshotCreatedAt"]))
#         age = age_hours(newest["snapshotCreatedAt"])
#
#         if age > MAX_AGE_HOURS:
#             errors.append(
#                 f"Longhorn: Latest backup for PVC '{pvc_label}' is {age:.1f}h old (max {MAX_AGE_HOURS}h)"
#             )
#         else:
#             logging.info(
#                 "OK: Longhorn backup for PVC '%s' is %.1fh old", pvc_label, age
#             )


def main() -> None:
    errors: list[str] = []
    test(test_zfs_snapshots, errors)
    # test(test_longhorn_backups, errors)
    notify(errors)


if __name__ == "__main__":
    main()
