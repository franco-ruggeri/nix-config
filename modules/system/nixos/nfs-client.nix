{ config, lib, ... }:
let
  cfg = config.myModules.system.nfs.client;
in
{
  options.myModules.system.nfs.client = {
    enable = lib.mkEnableOption "Enable NFS client for homelab";
    address = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    fileSystems."/mnt/nfs" = {
      device = "${cfg.address}:/";
      fsType = "nfs";
      options = [
        "nfsvers=4.2"
        "addr=${cfg.address}"
      ];
    };
  };
}
