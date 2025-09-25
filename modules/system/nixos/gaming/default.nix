# Based on https://wiki.nixos.org/wiki/Category:Gaming
{
  lib,
  config,
  ...
}:
let
  cfg = config.myModules.system.gaming;
in
{
  options.myModules.system.gaming.enable = lib.mkEnableOption "Enable gaming setup";

  config = lib.mkIf cfg.enable {
    programs = {
      gamemode.enable = true;
      steam.enable = true;
    };

    # TODO: try this stuff
    # environment.systemPackages = with pkgs; [
    #   heroic
    #   lutris
    #   mumble
    #   protonup-qt
    # ];
  };
}
