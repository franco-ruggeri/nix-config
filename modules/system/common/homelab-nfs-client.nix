{ lib, ... }:
{
  options.myModules.system.homelab.nfs.client = {
    enable = lib.mkEnableOption "Enable NFS client for homelab";
    serverAddress = lib.mkOption { type = lib.types.str; };
  };
}
