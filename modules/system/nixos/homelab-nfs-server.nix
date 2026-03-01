# Assumption:
# - The user has created a ZFS dataset named k8s-nfs with mountpoint=/mnt/zfs/k8s-nfs.
# - The user has created a ZFS dataset named k8s-longhorn with mountpoint=/mnt/zfs/k8s-longhorn.
{
  config,
  pkgs,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.system.homelab.nfs.server;
in
{
  options.myModules.system.homelab.nfs.server.enable =
    lib.mkEnableOption "Enable NFS server for homelab";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.myModules.system.zfs.enable;
        message = "ZFS must be enabled for NFS server.";
      }
    ];

    environment.systemPackages = with pkgs; [ python3 ];

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

    # NFS exports:
    # * k8s-nfs: read-write access from K8s nodes and K8s cluster.
    # * k8s-backup: read-only access from backup servers.
    #
    # The no_root_squash option is needed:
    # * read-write: for NextCloud to work property.
    #   See https://github.com/nextcloud/helm/issues/588
    # * read-only: for backup servers to be able to read files as root.
    services.nfs.server =
      let
        rwOptions = "rw,no_root_squash";
        roOptions = "ro,no_root_squash,crossmnt";
        rootOptions = "${roOptions},fsid=0";
        rwIPs = [
          "192.168.1.30/32"
          "10.34.0.2/32"
          "10.42.0.0/24"
        ];
        roIPs = [
          "10.34.0.3/32"
          "10.34.0.5/32"
          "10.34.0.6/32"
        ];
        rootExport = myLib.mkNfsExport {
          allowedIPs = rwIPs ++ roIPs;
          options = rootOptions;
        };
        rwExport = myLib.mkNfsExport {
          allowedIPs = rwIPs;
          options = rwOptions;
        };
        roExport = myLib.mkNfsExport {
          allowedIPs = roIPs;
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

    systemd =
      let
        pythonScriptDir = myLib.mkPythonScriptDir {
          derivationName = "homelab_backup_source";
          scriptNames = [
            "homelab_backup_source.py"
            "homelab_backup_utils.py"
          ];
        };
      in
      {
        services.homelab-backup = {
          description = "Homelab backup";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pythonScriptDir}/homelab_backup_source.py";
            WorkingDirectory = pythonScriptDir;
            Environment = [
              "PATH=/run/current-system/sw/bin/:/usr/bin:/bin:/usr/sbin:/sbin"
              "SMTP_PASSWORD_FILE=${config.age.secrets.smtp-password.path}"
            ];
          };
        };
        timers.homelab-backup = {
          description = "Homelab backup";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "01:00";
            Persistent = true;
          };
        };
      };

    age.secrets = myLib.mkSecrets [ "smtp-password" ];
  };
}
