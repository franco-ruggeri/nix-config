# Assumption:
# - The user has created a ZFS dataset named k8s-nfs with mountpoint=/mnt/zfs/k8s-nfs.
# - The user has created a ZFS dataset named k8s-longhorn with mountpoint=/mnt/zfs/k8s-longhorn.
{
  config,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.system.homelab.nfs;
  rwIPs =
    cfg.rwIPs
    ++ lib.optionals cfg.production [ "10.42.0.0/16" ]
    ++ lib.optionals (!cfg.production) [ "10.45.0.0/16" ];
in
{
  options.myModules.system.homelab.nfs = {
    enable = lib.mkEnableOption "Enable NFS server for homelab";
    rwIPs = lib.mkOption { type = lib.types.listOf lib.types.str; };
    roIPs = lib.mkOption { type = lib.types.listOf lib.types.str; };
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

    # The no_root_squash option is needed:
    # * read-write: for NextCloud to work property.
    #   See https://github.com/nextcloud/helm/issues/588
    # * read-only: for backup servers to be able to read files as root.
    services.nfs.server =
      let
        rwOptions = "rw,no_root_squash";
        roOptions = "ro,no_root_squash,crossmnt";
        rootOptions = "${roOptions},fsid=0";
        rootExport = myLib.mkNfsExport {
          allowedIPs = rwIPs ++ cfg.roIPs;
          options = rootOptions;
        };
        rwExport = myLib.mkNfsExport {
          allowedIPs = rwIPs;
          options = rwOptions;
        };
        roExport = myLib.mkNfsExport {
          allowedIPs = cfg.roIPs;
          options = roOptions;
        };
        nonRootExport = "${rwExport} ${roExport}";
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
