#!/usr/bin/env bash

nix run github:nix-community/home-manager/release-25.05 -- switch --flake .#desktop
