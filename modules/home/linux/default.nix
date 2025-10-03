{
  config,
  lib,
  myLib,
  ...
}:
{
  imports = [
    ./gui
    ./tui
  ];

  config = lib.mkIf myLib.isLinux {
    home.homeDirectory = /home/${config.myModules.home.username};
  };
}
