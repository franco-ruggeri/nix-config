import argparse

from . import src, zfs_pull, rsync_pull


def main() -> None:
    parser = argparse.ArgumentParser(prog="homelab-backup")
    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("src")

    dst_parser = subparsers.add_parser("dst")
    dst_parser.add_argument("--mode", choices=["zfs", "rsync"], required=True)

    args = parser.parse_args()

    if args.command == "src":
        src.main()
    elif args.command == "dst":
        if args.mode == "zfs":
            zfs_pull.main()
        else:
            rsync_pull.main()


if __name__ == "__main__":
    main()
