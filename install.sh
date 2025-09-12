#!/usr/bin/env bash

# Overwrite existing files
if [ "$1" = "--force" ]; then
	stow --target=$HOME --no-folding --adopt .
	git restore .
fi

stow --target=$HOME --no-folding .
if [ $? -ne 0 ]; then
	echo "Tip: Use --force to overwrite existing files."
	exit 1
fi
