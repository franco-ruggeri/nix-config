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
      # Only daily snapshots, as restic backups are done daily.
      # Keep last 7 days to have a large margin for restic backups to finish
      daily = 7;
      frequent = 0;
      hourly = 0;
      weekly = 0;
      flags = "--utc";
    };
  };
}
