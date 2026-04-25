# Assumptions:
# - All the assumptions in the NFS module.
# - A ZFS dataset named zfs/k8s-backup exists with mountpoint=/mnt/zfs/k8s-backup.
# - The ZFS dataset named zfs/k8s-backup has ZFS send delegations granted to the main user.
{
  config,
  pkgs,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.system.homelab.backupSrc;
  mainUser = config.myModules.system.username;
  mainHome = "/home/${mainUser}";
  zfsDatasets = [
    "zfs/k8s-nfs"
    "zfs/k8s-longhorn"
  ];
  homelabBackup = myLib.mkPythonApplication "homelab-backup";
in
{
  options.myModules.system.homelab.backupSrc.enable =
    lib.mkEnableOption "Enable backup source for homelab";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.myModules.system.homelab.wireguard.enable;
        message = "WireGuard client must be enabled for homelab backup source.";
      }
      {
        assertion = config.myModules.system.zfs.enable;
        message = "ZFS must be enabled for homelab backup source.";
      }
      {
        assertion = config.myModules.system.homelab.nfs.enable;
        message = "NFS server must be enabled on the backup source host.";
      }
    ];

    environment.systemPackages = with pkgs; [
      restic
    ];

    systemd = {
      services.homelab-backup-restic = {
        description = "Homelab backup restic on source";
        serviceConfig = {
          Type = "oneshot";
          User = mainUser;
          ExecStart = "${homelabBackup}/bin/homelab-backup restic";
          Environment = [
            "PATH=/run/current-system/sw/bin/:/usr/bin:/bin:/usr/sbin:/sbin"
            "HOME=${mainHome}"
            "RESTIC_PASSWORD_FILE=${config.age.secrets.restic-password.path}"
            "RESTIC_REPOSITORY=/mnt/zfs/k8s-backup"
            "RESTIC_CACHE_DIR=/tmp/restic-cache"
            "ZFS_MOUNT_ROOT=/mnt/zfs"
            "ZFS_DATASETS=${lib.concatStringsSep "," zfsDatasets}"
            "SMTP_PASSWORD_FILE=${config.age.secrets.smtp-password.path}"
            # Needed to avoid considering all files changed for every new ZFS snapshot.
            # See https://forum.restic.net/t/backing-up-zfs-snapshots-good-idea/9604
            "RESTIC_FEATURES=device-id-for-hardlinks"
          ];
        };
      };

      timers.homelab-backup-restic = {
        description = "Homelab backup restic on source";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "02:00";
          Persistent = true;
        };
      };
    };

    age.secrets =
      let
        smtpSecret = (myLib.mkSecrets [ "smtp-password" ])."smtp-password";
        resticSecret = (myLib.mkSecrets [ "restic-password" ])."restic-password";
      in
      {
        "smtp-password" = smtpSecret // {
          owner = mainUser;
          group = mainUser;
        };
        "restic-password" = resticSecret // {
          owner = mainUser;
          group = mainUser;
        };
      };
  };
}
