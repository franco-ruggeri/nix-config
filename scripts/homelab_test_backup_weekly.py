#!/usr/bin/env python3

import logging

from homelab_test_backup_utils import notify, run, test


def test_restic_metadata() -> None:
    run(["restic", "check"])
    logging.info("Restic: Restic metadata is valid.")


def main() -> None:
    errors: list[str] = []
    test(test_fn=test_restic_metadata, errors=errors)
    notify(errors)


if __name__ == "__main__":
    main()
