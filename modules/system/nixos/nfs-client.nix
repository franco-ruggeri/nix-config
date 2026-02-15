{ config, lib, ... }:
let
  cfg = config.myModules.system.nfs.client;
in
{
  config = lib.mkIf cfg.enable {
    fileSystems."/mnt/nfs" = {
      device = "${cfg.serverAddress}:/";
      fsType = "nfs";
      options = [
        "nfsvers=4.2"
        "addr=${cfg.serverAddress}"
      ];
    };
  };
}
