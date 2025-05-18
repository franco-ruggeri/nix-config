# Dotfiles

This repository contains my dotfiles.

## Using locally

Clone the repo:

```bash
git clone git@github.com:franco-ruggeri/dotfiles.git
```

Install dotfiles:

```bash
./install.sh
```

Uninstall dotfiles:

```bash
./uninstall.sh
```

## Using in dev containers

The repository is compatible with [`devpod`](https://devpod.sh/) for usage within dev containers.

Requirements:

- [`stow`](https://www.gnu.org/software/stow/) (e.g., use [this feature](https://github.com/kreemer/features/tree/main/src/stow))
- [`node`](https://nodejs.org/en) (e.g., use [this feature](https://github.com/devcontainers/features/tree/main/src/node))

Install dotfiles:

```bash
devpod up --dotfiles git@github.com:franco-ruggeri/dotfiles.git <workspace-path|workspace-id>
```
