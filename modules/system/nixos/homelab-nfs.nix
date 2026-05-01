# Assumption: The ZFS datasets zfs/k8s-nfs and zfs/k8s-longhorn exist with
# mountpoints /mnt/zfs/k8s-nfs and /mnt/zfs/k8s-longhorn.
{
  config,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.system.homelab.nfs;
  allowedIPs =
    cfg.allowedIPs
    ++ lib.optionals cfg.production [ "10.42.0.0/16" ]
    ++ lib.optionals (!cfg.production) [ "10.45.0.0/16" ];
in
{
  options.myModules.system.homelab.nfs = {
    enable = lib.mkEnableOption "Enable NFS server for homelab";
    allowedIPs = lib.mkOption { type = lib.types.listOf lib.types.str; };
    production = lib.mkOption { type = lib.types.bool; };
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
        # Options from https://wiki.archlinux.org/title/ZFS#Bind_mount
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
        "/srv/nfs/k8s-longhorn" = {
          device = "/mnt/zfs/k8s-longhorn";
          inherit options;
        };
      };

    # The no_root_squash option is needed for NextCloud to work property.
    # See https://github.com/nextcloud/helm/issues/588
    services.nfs.server =
      let
        rootExport = myLib.mkNfsExport {
          allowedIPs = allowedIPs;
          options = "ro,no_root_squash,crossmnt,fsid=0";
        };
        nonRootExport = myLib.mkNfsExport {
          allowedIPs = allowedIPs;
          options = "rw,no_root_squash";
        };
      in
      {
        enable = true;
        exports = ''
          /srv/nfs ${rootExport}
          /srv/nfs/k8s-nfs ${nonRootExport}
          /srv/nfs/k8s-longhorn ${nonRootExport}
        '';
      };

  };
}
