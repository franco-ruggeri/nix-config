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

  config = lib.mkIf (myLib.isDarwin) {
    home.homeDirectory = /Users/${config.myModules.home.username};
  };
}
