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
  cfg = config.myModules.system.nfs.server;
in
{
  options.myModules.system.nfs.server.enable = lib.mkEnableOption "Enable NFS server for homelab";

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
        "/srv/nfs/k8s-backup/nfs" = {
          device = "/mnt/zfs/k8s-nfs/.zfs/snapshot";
          inherit options;
        };
        "/srv/nfs/k8s-backup/longhorn" = {
          device = "/mnt/zfs/k8s-longhorn/.zfs/snapshot";
          inherit options;
        };
      };

    # NFS exports:
    # * k8s-nfs: read-write access from K8s nodes.
    # * k8s-backup: read-only access from backup servers.
    #
    # The no_root_squash option is needed:
    # * read-write: for NextCloud to work property.
    #   See https://github.com/nextcloud/helm/issues/588
    # * read-only: for backup servers to be able to read files as root.
    services.nfs.server =
      let
        rwOptions = "rw,no_root_squash";
        roOptions = "ro,no_root_squash";
      in
      {
        enable = true;
        exports = ''
          /srv/nfs 10.34.0.0/24(${roOptions},fsid=0)
          /srv/nfs/k8s-nfs 10.34.0.2/32(${rwOptions})
          /srv/nfs/k8s-longhorn 10.34.0.2/32(${rwOptions})
          /srv/nfs/k8s-backup/nfs 10.34.0.3/32(${roOptions}) 10.34.0.5/32(${roOptions}) 10.34.0.6/32(${roOptions})
          /srv/nfs/k8s-backup/longhorn 10.34.0.3/32(${roOptions}) 10.34.0.5/32(${roOptions}) 10.34.0.6/32(${roOptions})
        '';
      };

    systemd = {
      services.nfs-backup = {
        description = "NFS snapshot service";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = myLib.mkShellScript "nfs-snapshot.sh";
        };
      };
      timers.nfs-backup = {
        description = "NFS snapshot timer";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "01:00";
        };
      };
    };
  };
}
