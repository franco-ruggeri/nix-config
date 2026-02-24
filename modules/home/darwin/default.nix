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
    ./homelab-backup.nix
  ];

  config = lib.mkIf (myLib.isDarwin) {
    home.homeDirectory = /Users/${config.myModules.home.username};
  };
}
