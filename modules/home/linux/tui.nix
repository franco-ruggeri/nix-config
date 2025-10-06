{
  config,
  lib,
  myLib,
  ...
}:
{
  config = lib.mkIf (myLib.isLinux && config.myModules.home.tui.enable) { };
}
