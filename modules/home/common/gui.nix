{
  config,
  pkgs,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.home.gui;
in
{
  options.myModules.home.gui.enable = lib.mkEnableOption "Enable GUI home configuration.";

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        zotero
        bitwarden-desktop
        telegram-desktop
        spotify
        discord
        super-productivity
        zoom-us
        slack
        obsidian
      ];
    };

    programs = {
      firefox.enable = true;
      mpv.enable = true;
    };

    xdg.configFile = myLib.mkConfigDotfiles [
      "ghostty"
      "mpv"
      "discord"
    ];
  };
}
