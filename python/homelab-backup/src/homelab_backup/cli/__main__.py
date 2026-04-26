import argparse
import logging

from homelab_backup.cli import dst_rsync, dst_zfs, src


def main() -> None:
    logging.basicConfig(level=logging.INFO)
    parser = argparse.ArgumentParser(prog="homelab-backup")
    parser.add_argument("command", choices=["src", "dst-zfs", "dst-rsync"])
    args = parser.parse_args()

    if args.command == "src":
        src.main()
    elif args.command == "dst-zfs":
        dst_zfs.main()
    elif args.command == "dst-rsync":
        dst_rsync.main()
    else:
        raise ValueError(f"Unknown command: {args.command}")


if __name__ == "__main__":
    main()
