import argparse
import logging

from homelab_backup.cli import dest_rsync, dest_zfs, source


def main() -> None:
    logging.basicConfig(level=logging.INFO)
    parser = argparse.ArgumentParser(prog="homelab-backup")
    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("source")

    dest_parser = subparsers.add_parser("dest")
    dest_subparsers = dest_parser.add_subparsers(dest="dest_command", required=True)
    dest_subparsers.add_parser("rsync")
    dest_subparsers.add_parser("zfs")

    args = parser.parse_args()

    if args.command == "source":
        source.main()
    elif args.command == "dest":
        if args.dest_command == "rsync":
            dest_rsync.main()
        elif args.dest_command == "zfs":
            dest_zfs.main()


if __name__ == "__main__":
    main()
