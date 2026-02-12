{ config, lib, ... }:
let
  cfg = config.myModules.system.nfs.server;
in
{
  options.myModules.system.nfs.server = {
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

    # NFS exports:
    # * k8s-nfs: read-write, available for the K8s nodes.
    # * k8s-nfs-backup: read-only, available for the backup servers.
    #
    # no_root_squash is needed for NextCloud to work property.
    # See https://github.com/nextcloud/helm/issues/588
    services.nfs.server = {
      enable = true;
      exports = ''
        /srv/nfs 10.34.0.0/24(ro,fsid=0)
        /srv/nfs/k8s-nfs 10.34.0.2/32(rw,no_root_squash)
        /srv/nfs/k8s-nfs-backup 10.34.0.0/24(ro)
      '';
    };
  };
}
