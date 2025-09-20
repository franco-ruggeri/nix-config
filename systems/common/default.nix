{ pkgs, lib, mylib, nixpkgs-unstable, ... }:

let pkgsUnstable = import nixpkgs-unstable { system = pkgs.system; };
in {
  home-manager.extraSpecialArgs = { inherit mylib pkgsUnstable; };

  nix = {
    settings.experimental-features = "nix-command flakes";
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
  };

  programs.zsh.enable = true;

  fonts.packages = builtins.filter lib.attrsets.isDerivation
    (builtins.attrValues pkgs.nerd-fonts); # all nerd fonts
}
