# Assumptions:
# - The user has created a ZFS pool named zfs.
# - The user has set the com.sun:auto-snapshot property to true for the ZFS dataset to auto-snapshot.
{ config, lib, ... }:
let
  cfg = config.myModules.system.zfs;
in
{
  options.myModules.system.zfs.enable = lib.mkEnableOption "Enable ZFS pool loading";

  config = lib.mkIf cfg.enable {
    boot = {
      supportedFilesystems = [ "zfs" ];
      zfs.extraPools = [ "zfs" ];
    };

    services.zfs.autoSnapshot = {
      enable = true;
      flags = "--utc";
    };
  };
}
