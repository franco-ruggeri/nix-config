{ config, lib, ... }:
let
  cfg = config.myModules.system.tui;
in
{
  options.myModules.system.tui.enable = lib.mkEnableOption "Enable TUI system configuration.";

  config = lib.mkIf cfg.enable {
    programs.zsh.enable = true;
  };
}
