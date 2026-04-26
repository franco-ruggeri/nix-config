import argparse
import logging

from homelab_backup.cli import dest_rsync_main, dest_zfs_main, source_main


def main() -> None:
    logging.basicConfig(level=logging.INFO)
    parser = argparse.ArgumentParser(prog="homelab-backup")
    parser.add_argument("command", choices=["src", "dest-zfs", "dest-rsync"])
    args = parser.parse_args()

    if args.command == "src":
        source_main()
    elif args.command == "dest-zfs":
        dest_zfs_main()
    elif args.command == "dest-rsync":
        dest_rsync_main()
    else:
        raise ValueError(f"Unknown command: {args.command}")


if __name__ == "__main__":
    main()
