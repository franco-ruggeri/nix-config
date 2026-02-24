{ config, pkgs, ... }:
let
  cfg = config.myModules.system;
in
{
  imports = [
    ../common
    ./gui.nix
    ./tui.nix
    ./homelab-nfs-client.nix
  ];

  users.users.${cfg.username} = {
    home = /Users/${cfg.username};
    shell = pkgs.zsh;
  };

  system.primaryUser = cfg.username;

  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
  };
}
