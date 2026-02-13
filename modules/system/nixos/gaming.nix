# Based on https://wiki.nixos.org/wiki/Category:Gaming
{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.myModules.system.gaming;
in
{
  options.myModules.system.gaming.enable = lib.mkEnableOption "Enable gaming setup";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.myModules.system.gui.enable;
        message = "GUI must be enabled for the gaming setup.";
      }
    ];

    programs = {
      gamemode.enable = true;
      gamescope.enable = true;
      steam = {
        enable = true;
        gamescopeSession.enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      mangohud
      heroic
      protonup-qt
    ];
  };
}
