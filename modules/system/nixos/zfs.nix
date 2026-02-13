# Assumption: The user has created a ZFS pool named zfs.
{ config, lib, ... }:
let
  cfg = config.myModules.system.zfs;
in
{
  options.myModules.system.zfs = {
    enable = lib.mkEnableOption "Enable ZFS pool loading";
  };

  config = lib.mkIf cfg.enable {
    boot = {
      supportedFilesystems = [ "zfs" ];
      zfs.extraPools = [ "zfs" ];
    };
  };
}
