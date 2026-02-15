{ lib, ... }:
{
  options.myModules.system.nfs.client = {
    enable = lib.mkEnableOption "Enable NFS client for homelab";
    serverAddress = lib.mkOption { type = lib.types.str; };
  };
}
