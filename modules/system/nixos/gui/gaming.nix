# Based on https://wiki.nixos.org/wiki/Category:Gaming
{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.myModules.system.gui.gaming;
in
{
  options.myModules.system.gui.gaming.enable = lib.mkEnableOption "Enable gaming setup";

  config = lib.mkIf cfg.enable {
    programs = {
      gamemode.enable = true;
      steam.enable = true;
    };
    environment.systemPackages = with pkgs; [
      heroic
      lutris
      protonup-qt
    ];
  };
}
