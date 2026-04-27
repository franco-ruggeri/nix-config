import argparse
import logging

from homelab_backup.cli import dest_rsync, dest_zfs, source


def main() -> None:
    logging.basicConfig(level=logging.INFO)
    parser = argparse.ArgumentParser(prog="homelab-backup")
    parser.add_argument("command", choices=["source", "dest-rsync", "dest-zfs"])
    args = parser.parse_args()

    if args.command == "source":
        source.main()
    elif args.command == "dest-rsync":
        dest_rsync.main()
    elif args.command == "dest-zfs":
        dest_zfs.main()


if __name__ == "__main__":
    main()
