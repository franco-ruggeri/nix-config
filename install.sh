#!/bin/bash

# Trick to drop existing files, if present
stow --target=$HOME --no-folding --adopt .
git restore .

# Actual installation
stow --target=$HOME --no-folding .
