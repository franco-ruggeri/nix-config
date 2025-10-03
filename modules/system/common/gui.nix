{ lib, ... }:
{
  options.myModules.system.gui.enable = lib.mkEnableOption "Enable GUI system configuration.";
}
