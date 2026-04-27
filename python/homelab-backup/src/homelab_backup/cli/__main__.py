import argparse
import logging

from homelab_backup.cli import dst_rsync, dst_zfs, src


def main() -> None:
    logging.basicConfig(level=logging.INFO)
    parser = argparse.ArgumentParser(prog="homelab-backup")
    parser.add_argument("command", choices=["src", "dst-rsync", "dst-zfs"])
    args = parser.parse_args()

    if args.command == "src":
        src.main()
    elif args.command == "dst-rsync":
        dst_rsync.main()
    elif args.command == "dst-zfs":
        dst_zfs.main()


if __name__ == "__main__":
    main()
