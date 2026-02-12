{ config, lib, ... }:
let
  cfg = config.myModules.system.nfs;
in
{
  options.myModules.system.nfs = {
    enable = lib.mkEnableOption "Enable NFS server for homelab";
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 2049 ];

    fileSystems = {
      "/srv/nfs/k8s-nfs" = {
        device = "/mnt/zfs/k8s-nfs";
        options = [ "bind" ];
      };
      "/srv/nfs/k8s-nfs-backup" = {
        device = "/mnt/zfs/k8s-nfs";
        options = [ "bind" ];
      };
    };

    services.nfs.server = {
      enable = true;
      exports = ''
        /srv/nfs 192.168.1.30/32(ro,fsid=0) 10.34.0.0/24(ro,fsid=0)
        /srv/nfs/k8s-nfs 192.168.1.30/32(rw,no_root_squash)
        /srv/nfs/k8s-nfs-backup 10.34.0.0/24(ro)
      '';
    };
  };
}
