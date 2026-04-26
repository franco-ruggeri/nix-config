import argparse
import logging

from homelab_backup.cli import dest_rsync, dest_zfs, source


def main() -> None:
    logging.basicConfig(level=logging.INFO)
    parser = argparse.ArgumentParser(prog="homelab-backup")
    parser.add_argument("command", choices=["src", "dest-zfs", "dest-rsync"])
    args = parser.parse_args()

    if args.command == "src":
        source.main()
    elif args.command == "dest-zfs":
        dest_zfs.main()
    elif args.command == "dest-rsync":
        dest_rsync.main()
    else:
        raise ValueError(f"Unknown command: {args.command}")


if __name__ == "__main__":
    main()
