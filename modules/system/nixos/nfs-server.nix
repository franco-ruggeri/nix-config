# Assumptions: The user has created a ZFS dataset named k8s-nfs with mountpoint=/mnt/k8s-nfs.
{ config, lib, ... }:
let
  cfg = config.myModules.system.nfs.server;
in
{
  options.myModules.system.nfs.server = {
    enable = lib.mkEnableOption "Enable NFS server for homelab";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.myModules.system.zfs.enable;
        message = "ZFS must be enabled for NFS server.";
      }
    ];

    networking.firewall.allowedTCPPorts = [ 2049 ];

    fileSystems =
      let
        options = [
          "bind"
          "nofail"
          "x-systemd.requires=zfs-mount.service"
        ];
      in
      {
        "/srv/nfs/k8s-nfs" = {
          device = "/mnt/zfs/k8s-nfs";
          inherit options;
        };
        "/srv/nfs/k8s-nfs-ro" = {
          device = "/mnt/zfs/k8s-nfs";
          inherit options;
        };
      };

    # NFS exports:
    # * k8s-nfs: read-write access from K8s nodes.
    # * k8s-nfs-ro: read-only access from backup servers.
    #
    # Note: no_root_squash is needed for NextCloud to work property.
    # See https://github.com/nextcloud/helm/issues/588
    services.nfs.server = {
      enable = true;
      exports = ''
        /srv/nfs 10.34.0.0/24(ro,fsid=0)
        /srv/nfs/k8s-nfs 10.34.0.2/32(rw,no_root_squash)
        /srv/nfs/k8s-nfs-ro 10.34.0.3/24 10.34.0.5/24(ro) 10.34.0.6/24(ro)
      '';
    };
  };
}
