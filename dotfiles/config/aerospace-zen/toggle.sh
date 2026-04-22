#!/usr/bin/env bash

# HACK: Zen-mode in AeroSpace. Remove when AeroSpace implements it.
# See https://github.com/nikitabobko/AeroSpace/discussions/2061

# Swap the two aerospace configs to toggle zen-mode.
# Based on https://github.com/nikitabobko/AeroSpace/issues/60#issuecomment-3063386260

tmpdir="$(mktemp -d)"

dst="$HOME/.config/aerospace/aerospace.toml"
src="$HOME/.config/aerospace-zen/aerospace.toml"
tmp="$tmpdir/aerospace.toml"

mv "$dst" "$tmp"
mv "$src" "$dst"
mv "$tmp" "$src"

rmdir "$tmpdir"

"$HOME/.nix-profile/bin/aerospace" reload-config
