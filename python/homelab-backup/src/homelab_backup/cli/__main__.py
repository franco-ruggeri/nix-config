import argparse
import logging

from homelab_backup.cli import dst_rsync, dst_zfs, src


def main() -> None:
    logging.basicConfig(level=logging.INFO)
    parser = argparse.ArgumentParser(prog="homelab-backup")
    parser.add_argument("command", choices=["src", "dst-rsync", "dst-zfs"])
    parser.add_argument(
        "--full", action="store_true", help="Force full ZFS transfer instead of incremental (dst-zfs only)"
    )
    args = parser.parse_args()

    if args.command == "src":
        src.main()
    elif args.command == "dst-rsync":
        dst_rsync.main()
    elif args.command == "dst-zfs":
        dst_zfs.main(full=args.full)


if __name__ == "__main__":
    main()
