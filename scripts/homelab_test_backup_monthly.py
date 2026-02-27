#!/usr/bin/env python3

import logging

from homelab_test_backup_utils import notify, run, test


def test_restic_data() -> None:
    run(["restic", "check", "--read-data"])
    logging.info("Restic: Restic data is valid.")


def main() -> None:
    errors: list[str] = []
    test(test_fn=test_restic_data, errors=errors)
    notify(errors)


if __name__ == "__main__":
    main()
