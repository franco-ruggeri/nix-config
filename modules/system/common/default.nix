{ pkgs, lib, ... }:
{
  imports = [
    ./gui.nix
    ./tui.nix
    ./homelab-nfs-client.nix
  ];

  options.myModules.system.username = lib.mkOption { type = lib.types.str; };

  config = {
    nix = {
      settings.experimental-features = "nix-command flakes";
      gc.automatic = true;
    };

    fonts.packages = builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts); # all nerd fonts
  };
}
