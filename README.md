# Dotfiles

This repository contains my Nix configurations. The structure of the repository
is inspired by
[Ryan Yin's template](https://github.com/ryan4yin/nix-config/tree/i3-kickstarter).

On NixOS:

```bash
sudo nixos-rebuild switch --flake .#desktop
```

On macOS:

```bash
sudo darwin-rebuild switch --flake .#laptop
```

- [ ] TODO: update the rest of the README.
- [ ] TODO: multi-user. I want to be able to enable only specific user modules
      for each user. update: need to make the modules optional with the enable
      option, and then activate them from the user config.
- [x] TODO: I need the concept of system... like users have their config (e.g.,
      enabled modules), systems do as well. So, a host is hardware + system +
      users
- [ ] TODO: update dev container usage

## Using in dev containers

The repository is compatible with [`devpod`](https://devpod.sh/) for usage
within dev containers. Follow
[the documentation](https://devpod.sh/docs/developing-in-workspaces/dotfiles-in-a-workspace)
for instructions.

The installation uses [`stow`](https://www.gnu.org/software/stow/). Thus, make
sure the dev container has it by adding
[this feature](https://github.com/kreemer/features/tree/main/src/stow).
