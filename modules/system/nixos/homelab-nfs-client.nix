{ config, lib, ... }:
let
  cfg = config.myModules.system.homelab.nfs.client;
in
{
  config = lib.mkIf cfg.enable {
    fileSystems."/mnt/nfs" = {
      device = "${cfg.serverAddress}:/";
      fsType = "nfs";
      options = [
        "nfsvers=4.2"
        "addr=${cfg.serverAddress}"
        # Lazy-mounting
        # See https://nixos.wiki/wiki/NFS#Lazy-mounting
        # ====================
        "x-systemd.automount"
        "noauto"
        # ====================
      ];
    };
  };
}
