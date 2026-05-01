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
  config = lib.mkIf (myLib.isDarwin && cfg.enable) {
    home.packages = with pkgs; [
      whatsapp-for-mac
      zathura
    ];

    programs = {
      aerospace = {
        enable = true;
        userSettings = builtins.fromTOML (
          builtins.readFile (myLib.dotfilesDir + "/.config/aerospace/aerospace.toml")
        );
      };
    };

    xdg.configFile = myLib.mkDotfiles [
      ".config/karabiner"
    ];
  };
}
