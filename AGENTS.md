# AGENTS.md — Nix Config Coding Guide

This file provides guidance for agentic coding tools (e.g., Claude, Copilot,
Cursor) working in this repository.

---

## Project Overview

A personal Nix monorepo using **flake-parts** to manage:

- **NixOS** system configurations (`hosts/nixos/`)
- **nix-darwin** system configurations (`hosts/darwin/`)
- **home-manager** standalone home configurations (`hosts/home/`)

Key inputs: `nixpkgs` (25.05), `nixpkgs-unstable`, `home-manager`, `nix-darwin`,
`agenix`, `mac-app-util`, `flake-parts`.

---

## Repository Structure

```
flake.nix             # Flake entry point (delegates to ./flake)
flake/                # flake-parts modules: hosts.nix, modules.nix, packages.nix
hosts/                # Per-machine configurations (nixos/, darwin/, home/)
modules/              # Reusable opt-in modules (home/ and system/)
  home/               #   common/, linux/, darwin/
  system/             #   common/, nixos/, darwin/
lib/                  # Shared helper functions (myLib)
pkgs/                 # Custom packages via overlay
files/                # Managed files (dot/ → ~/.config + ~/.local, etc/ → /etc)
scripts/              # Python scripts used by homelab modules
secrets/              # agenix-encrypted .age files + secrets.nix (public keys)
```

---

## Build / Apply Commands

There is no Makefile, justfile, or test suite. All commands are run manually.

### NixOS (system)

```bash
sudo nixos-rebuild switch --flake .#desktop
sudo nixos-rebuild switch --flake .#server-stockholm
sudo nixos-rebuild switch --flake .#server-turin
```

### nix-darwin (system)

```bash
sudo darwin-rebuild switch --flake .#laptop
```

### home-manager (standalone)

```bash
home-manager switch --flake .#desktop
home-manager switch --flake .#laptop
home-manager switch --flake .#server
home-manager switch --flake .#container-x86
home-manager switch --flake .#container-arm
```

### Dry-run / check (no activation)

```bash
nixos-rebuild dry-run --flake .#desktop
home-manager build --flake .#desktop
```

There are no unit tests. Validation is done by a successful build.

---

## Formatter

**`nixfmt-rfc-style`** is the sole Nix formatter. Run it on a file:

```bash
nixfmt path/to/file.nix
```

All other formatters are editor-driven via Neovim (null-ls): `stylua` (Lua),
`shfmt` (shell), `ruff` (Python), `prettier` (JSON/YAML/Markdown).

No linter configs (statix, deadnix) or pre-commit hooks exist.

---

## Code Style

### Nix Formatter

Always format Nix files with `nixfmt` (RFC style): 2-space indentation, opening
`{` on the same line as the function argument, one space inside `{` `}` for
inline sets, and trailing `;` on its own line for multi-line sets.

### Module Structure

All modules follow this exact structure:

```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.myModules.<scope>.<name>;
in
{
  options.myModules.<scope>.<name>.enable = lib.mkEnableOption "...";
  # additional options as needed

  config = lib.mkIf cfg.enable {
    # configuration here
  };
}
```

### Options Namespace

All custom options live under `myModules.*`:

- `myModules.home.*` — home-manager modules
- `myModules.system.*` — NixOS/Darwin system modules

Options declarations use only `type` (and `description` when helpful). Avoid
`default` unless necessary:

```nix
options.myModules.system.homelab.nfs.client = {
  enable = lib.mkEnableOption "Enable NFS client for homelab";
  serverIP = lib.mkOption { type = lib.types.str; };
  shares = lib.mkOption { type = lib.types.listOf lib.types.str; };
};
```

### Imports: Always Use Directories

Import directories (resolved via `default.nix`), never direct `.nix` file paths
— except for sibling files in the same directory:

```nix
# Correct (cross-directory)
imports = [ ../common ];

# Also OK (same-directory siblings)
imports = [ ./gui.nix ./tui.nix ./homelab-backup.nix ];

# Wrong — never do this cross-directory
imports = [ ../common/default.nix ];
```

### Package Lists

Use `with pkgs; [ ... ]` for all package lists:

```nix
home.packages = with pkgs; [
  tmux
  ripgrep
  fzf
];
```

### Attribute Set Merging

Use `//` for simple merges. Do not use `lib.mkMerge` unless module priority
conflicts require it:

```nix
age.secrets =
  myLib.mkSecrets [ "user-password" ]
  // myLib.mkWireguardSecrets [ "wg-key" ];
```

### Naming Conventions

| Context                         | Convention   | Example                                    |
| ------------------------------- | ------------ | ------------------------------------------ |
| Option names under `myModules`  | `camelCase`  | `tui.enable`, `nfs`                        |
| Module / host file names        | `kebab-case` | `homelab-backup.nix`, `server-stockholm`   |
| `myLib` helper functions        | `camelCase`  | `mkSecrets`, `isDarwin`, `mkNfsExport`     |
| Local `let` bindings            | `camelCase`  | `mkSecret`, `allowedIPWithOptions`         |
| systemd / launchd service names | `kebab-case` | `homelab-backup-restic`                    |
| systemd `serviceConfig` keys    | `PascalCase` | `ExecStart`, `Type`, `PermitRootDirectory` |

### `myLib` Usage

`myLib` is injected via `specialArgs` (NixOS/Darwin) or `extraSpecialArgs`
(home-manager). Use it for:

- `myLib.mkDotfiles [ ".config/nvim" ".config/tmux" ]` — install dotfiles from
  `files/dot/`
- `myLib.mkDotfiles [ ".local/share/hypr" ]` — install from `files/dot/`
- `myLib.mkSecrets [ "secret-name" ]` — generate `age.secrets` entries
- `myLib.mkWireguardSecrets [ "wg-key" ]` — secrets with WireGuard-specific
  permissions
- `myLib.mkShellScript "name"` — wrap a script from `scripts/`
- `myLib.mkPythonScriptDir { derivationName = ...; scriptNames = [...]; }` —
  package Python scripts
- `myLib.mkNfsExport { allowedIPs = [...]; options = "..."; }` — format NFS
  export strings
- `myLib.isDarwin` / `myLib.isLinux` — platform checks

### Platform-Conditional Config

```nix
config = lib.mkIf (myLib.isDarwin && cfg.enable) { ... };
```

### Commit Messages

- Summary line must be < 50 characters
- Use conventional commits format: `type(scope): summary`
- Common types: `feat`, `fix`, `refactor`, `chore`, `docs`

### Comments

- Reference upstream docs: `# Based on https://wiki.nixos.org/wiki/...`
- Document known issues: `# WARNING: <package> is broken, see <URL>`
- Guard stateVersion: `# DO NOT change!`

### `stateVersion`

Never change `system.stateVersion` or `home.stateVersion` — these are pinned to
the NixOS release when the machine was first installed.

### Secrets

All secrets are managed with **agenix**. Secret files live in `secrets/*.age`.
Public keys are in `secrets/secrets.nix`. Never commit unencrypted secret
values.

### Unstable Packages

`pkgs.unstable` is available via overlay (set up in `flake/packages.nix`). Use
it for packages that need a newer version than the stable channel provides.

### Python (in `python/`)

Format and lint with ruff:

```bash
ruff format python/homelab-backup/src
ruff check python/homelab-backup/src
```

Type-check with mypy (run from the package directory):

```bash
mypy --package homelab_backup
```

Ruff and mypy are configured in `python/homelab-backup/pyproject.toml`. Always
run both tools and fix all issues before committing.
