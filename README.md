# Nix Configurations

This repository contains my Nix configurations.

## Prerequisites

- Install `nix`.
- Install `home-manager` (standalone):

  ```bash
  nix shell github:nix-community/home-manager/release-25.05
  ```

## Install

### NixOS

Run:

```bash
sudo nixos-rebuild switch --flake .#desktop
home-manager switch --flake .#desktop
```

### MacOS

Run:

```bash
sudo darwin-rebuild switch --flake .#laptop
home-manager switch --flake .#laptop
```

### Dev containers

Add
[the `home-manager` feature](https://github.com/franco-ruggeri/devcontainer-features/tree/main/src/home-manager):

```json
"features": {
    "ghcr.io/franco-ruggeri/devcontainer-features/home-manager:0": {
        "username": "ubuntu",
        "flakeUri": "github:franco-ruggeri/nix-config#container"
    }
}
```

## Repository Structure

The repository is structured as follows:

```bash
.
├── dotfiles
│   ├── config
│   └── local
├── flake
├── hosts
│   ├── darwin
│   ├── home
│   └── nixos
├── lib
├── modules
│   ├── home
│   └── system
├── pkgs
...
```

where:

- `dotfiles`:
  - `dotfiles/config` contains dotfiles installed at `~/.config`.
  - `dotfiles/local` contains dotfiles installed at `~/.local`.
- `flake` contains [flake parts](https://flake.parts/).
- `hosts`:
  - `hosts/nixos` contains system configurations for NixOS machines.
  - `hosts/darwin` contains system configurations for macOS machines.
  - `hosts/home` contains home configurations for linux or darwin machines.
- `lib` contains common functions used in `modules`.
- `modules`:
  - `modules/home` contains home-manager modules imported in home
    configurations.
  - `modules/system` contains system modules imported in system configurations
    (NixOS or macOS).
- `pkgs` contains packages added to `nixpkgs` via overlay.

The repository structure is inspired by
[Ryan Yin's template](https://github.com/ryan4yin/nix-config/tree/i3-kickstarter).

## Coding Style

- Formatter: `nixfmt`
- Nix expressions imported from other directories should be imported as
  directories (e.g., `imports = [ ./path/to/dir ];` instead of
  `imports [ ./path/to/file.nix ];`. Files should be structured accordingly and
  eventually wrapped into directories having `default.nix`.
