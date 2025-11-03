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
      aerospace = {
        enable = true;
        userSettings = builtins.fromTOML (
          builtins.readFile (myLib.dotfilesConfigDir + "/aerospace/aerospace.toml")
        );
      };
    };

    xdg.configFile = myLib.mkConfigDotfiles [
      "karabiner"
    ];
  };
}
