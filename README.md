# Dotfiles

This repository contains my dotfiles.

## Using locally

Install dotfiles:

```bash
./install.sh
```

Uninstall dotfiles:

```bash
./uninstall.sh
```

## Using in dev containers

The repository is compatible with [`devpod`](https://devpod.sh/) for usage
within dev containers. Follow [the documentation](https://devpod.sh/docs/developing-in-workspaces/dotfiles-in-a-workspace)
for instructions.

Requirements:

- [`stow`](https://www.gnu.org/software/stow/) (e.g., use [this feature](https://github.com/kreemer/features/tree/main/src/stow))
- [`node`](https://nodejs.org/en) (e.g., use [this feature](https://github.com/devcontainers/features/tree/main/src/node))
