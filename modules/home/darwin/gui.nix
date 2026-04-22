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
          builtins.readFile (myLib.dotfilesConfigDir + "/aerospace/aerospace.toml")
        );
      };
    };

    xdg.configFile =
      myLib.mkConfigDotfiles [
        "karabiner"
      ]
      # HACK: Zen-mode in AeroSpace. Remove when AeroSpace implements it.
      # See https://github.com/nikitabobko/AeroSpace/discussions/2061
      # ====================
      # "aerospace-zen"
      // {
        "aerospace-zen/toggle.sh" = {
          source = myLib.dotfilesConfigDir + "/aerospace-zen/toggle.sh";
          executable = true;
        };
      }
      // {
        "aerospace-zen/aerospace.toml" = {
          source = myLib.dotfilesConfigDir + "/aerospace-zen/aerospace.toml";
        };
      };
    # ====================
  };
}
