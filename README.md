# Dotfiles

This repository contains my dotfiles.

## Using locally

Clone the repo:

```bash
git clone
```

Install dotfiles:

```bash
install.sh
```

Uninstall dotfiles:

```bash
./uninstall.sh
```

## Using in dev containers

The repository is compatible with [`devpod`](https://devpod.sh/) for usage within dev containers.

Install dotfiles:

```bash
devpod up --dotfiles git@github.com:franco-ruggeri/dotfiles.git <workspace-path|workspace-id>
```
