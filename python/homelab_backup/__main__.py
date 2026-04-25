import argparse

from . import k8s, restic, rsync_pull, zfs_pull


def main() -> None:
    parser = argparse.ArgumentParser(prog="homelab_backup")
    parser.add_argument(
        "command",
        choices=["restic", "zfs-pull", "rsync-pull", "k8s"],
    )
    args = parser.parse_args()

    if args.command == "restic":
        restic.main()
    elif args.command == "zfs-pull":
        zfs_pull.main()
    elif args.command == "rsync-pull":
        rsync_pull.main()
    else:
        k8s.main()


if __name__ == "__main__":
    main()
