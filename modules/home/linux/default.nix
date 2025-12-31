{
  config,
  lib,
  myLib,
  ...
}:
{
  imports = [
    ./gui.nix
    ./tui.nix
    ./cloud.nix
  ];

  config = lib.mkIf myLib.isLinux {
    home.homeDirectory = /home/${config.myModules.home.username};
  };
}
