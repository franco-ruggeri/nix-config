{
  config,
  pkgs,
  lib,
  myLib,
  ...
}:
{
  config = lib.mkIf (myLib.isDarwin && config.myModules.home.gui.enable) {
    home.packages = with pkgs; [ whatsapp-for-mac ];

    programs = {
      aerospace.enable = true;
    };

    xdg.configFile = myLib.mkConfigDotfiles [
      "aerospace"
      "karabiner"
    ];
  };
}
