{
  config,
  pkgs,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.home.tui;
in
{
  config = lib.mkIf (myLib.isDarwin && cfg.enable) {
    home.packages = with pkgs; [
      pngpaste # for obsidian.nvim image pasting
    ];

    programs.gpg.enable = true;
  };
}
