# Nix Configurations

This repository contains my Nix configurations.

TODO:

- [ ] update the rest of the README.
  - [ ] describe structure and concepts: host, user, system, modules. host =
        hardware + system + user(s). system = OS.
- [x] multi-user. I want to be able to enable only specific user modules for
      each user.
  - Update: need to make the modules optional with the enable option, and then
    activate them from the user config.
- [x] Move the dotfiles to users, not modules. They belong to the user.
      Different users, different dotfiles (maybe shared via common, but in
      principle each user has their dotfiles).
- [x] I need the concept of system... like users have their config (e.g.,
      enabled modules), systems do as well. So, a host is hardware + system +
      users
- [ ] update dev container usage

## Prerequisites

- Install `nix`.
- Install `home-manager` (standalone):

  ```bash
  nix run home-manager/release-25.05 -- init --switch
  rm -r ~/.config/home-manager
  ```

## Install

On NixOS:

```bash
sudo nixos-rebuild switch --flake .#desktop
home-manager switch --flake .#desktop
```

On macOS:

```bash
sudo darwin-rebuild switch --flake .#laptop
home-manager switch --flake .#laptop
```

## Structure

The structure of the repository is inspired by
[Ryan Yin's template](https://github.com/ryan4yin/nix-config/tree/i3-kickstarter).

---

not updated yet from here.

## Using in dev containers

The repository is compatible with [`devpod`](https://devpod.sh/) for usage
within dev containers. Follow
[the documentation](https://devpod.sh/docs/developing-in-workspaces/dotfiles-in-a-workspace)
for instructions.

The installation uses [`stow`](https://www.gnu.org/software/stow/). Thus, make
sure the dev container has it by adding
[this feature](https://github.com/kreemer/features/tree/main/src/stow).
