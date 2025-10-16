{
  config,
  pkgs,
  lib,
  myLib,
  ...
}:
{
  config = lib.mkIf (myLib.isDarwin && config.myModules.home.tui.enable) {
    home.packages = with pkgs; [
      pngpaste # for obsidian.nvim image pasting
    ];

    programs.gpg.enable = true;
  };
}
