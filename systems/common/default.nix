{
  pkgs,
  lib,
  myLib,
  ...
}:
{
  home-manager = {
    # Use pkgs instance from the system, configured in flake.nix
    # See https://nix-community.github.io/home-manager/
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit myLib; };
  };

  nix = {
    settings.experimental-features = "nix-command flakes";
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
  };

  programs.zsh.enable = true;

  fonts.packages = builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts); # all nerd fonts
}
