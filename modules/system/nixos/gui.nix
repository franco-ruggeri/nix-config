{ config, lib, ... }:
let
  cfg = config.myModules.system.gui;
in
{
  config = lib.mkIf cfg.enable {
    users.users.${config.myModules.system.username}.extraGroups = [ "ydotool" ];

    programs = {
      hyprland.enable = true;
      seahorse.enable = true;
      ydotool.enable = true; # for SpeechNote
    };

    services = {
      hardware.openrgb.enable = true;
      # WARNING: The home-manager module (services.gnome-keyring) does not work.
      # See https://github.com/nix-community/home-manager/issues/1454
      gnome.gnome-keyring.enable = true;
      # WARNING: Needed for Speech Note. When it gets added to Nixpkgs, use that and remove this.
      # See https://github.com/NixOS/nixpkgs/issues/306838
      flatpak.enable = true;
    };
  };
}
