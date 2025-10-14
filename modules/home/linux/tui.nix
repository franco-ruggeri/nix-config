{
  config,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.home.tui;
in
{
  config = lib.mkIf (myLib.isLinux && cfg.enable) { };
}
