{ pkgs, lib, ... }:
{
  imports = [
    ./gui.nix
    ./tui.nix
    ./nfs-client.nix
  ];

  options.myModules.system.username = lib.mkOption {
    type = lib.types.str;
    description = "The username of the main user.";
  };

  config = {
    nix = {
      settings.experimental-features = "nix-command flakes";
      gc.automatic = true;
    };

    fonts.packages = builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts); # all nerd fonts
  };
}
