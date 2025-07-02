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

The installation uses [`stow`](https://www.gnu.org/software/stow/). Thus,
make sure the dev container has it by adding [this
feature](https://github.com/kreemer/features/tree/main/src/stow).
