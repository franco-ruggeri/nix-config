{
  config,
  lib,
  myLib,
  ...
}:
{
  config = lib.mkIf (myLib.isDarwin && config.myModules.home.tui.enable) { };
}
