{ config, lib, ... }:
let
  cfg = config.myModules.system.gui;
in
{
  config = lib.mkIf cfg.enable {
    homebrew = {
      casks = [
        "google-drive"
        "adobe-acrobat-reader"
        # WARNING: The Nix option (services.karabiner-elements) is currently broken.
        # See https://github.com/nix-darwin/nix-darwin/issues/1041
        "karabiner-elements"
        # WARNING: The Nix option (programs.ghostty) is currently broken.
        # See https://github.com/NixOS/nixpkgs/issues/388984
        "ghostty"
        # WARNING: The Nix package (pkgs.obs-studio) does not support darwin currently.
        # See https://github.com/NixOS/nixpkgs/issues/411190
        "obs"
        # WARNING: The Nix package (pkgs.wireshark) does not set up permissions.
        "wireshark-app"
      ];
      masApps = { };
    };
  };
}
