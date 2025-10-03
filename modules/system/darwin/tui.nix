{ config, lib, ... }:
let
  cfg = config.myModules.system.tui;
in
{
  config = lib.mkIf cfg.enable {
    homebrew = {
      brews = [ ];
    };
  };
}
