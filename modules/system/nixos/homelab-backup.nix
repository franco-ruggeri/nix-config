# Assumption: The user has created a ZFS dataset named k8s-backup with mountpoint=/mnt/zfs/k8s-backup.
{
  config,
  pkgs,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.system.homelab.backup;
in
{
  options.myModules.system.homelab.backup.enable = lib.mkEnableOption "Enable backups for homelab";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.myModules.system.homelab.nfs.client.enable;
        message = "NFS client must be enabled for NFS backup.";
      }
    ];

    environment.systemPackages = with pkgs; [
      restic
      python3
    ];

    systemd =
      let
        pythonScriptDir = myLib.mkPythonScriptDir {
          derivationName = "homelab_backup_daily";
          scriptNames = [
            "homelab_backup_server.py"
            "homelab_backup_utils.py"
          ];
        };
      in
      {
        services.homelab-backup = {
          description = "Homelab make backup";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pythonScriptDir}/homelab_backup_server.py";
            WorkingDirectory = pythonScriptDir;
            Environment = [
              "PATH=/run/current-system/sw/bin/:/usr/bin:/bin:/usr/sbin:/sbin"
              "NFS_SERVER_ADDRESS=${config.myModules.system.homelab.nfs.client.serverAddress}"
              "RESTIC_PASSWORD_FILE=${config.age.secrets.restic-password.path}"
              "RESTIC_REPOSITORY=/mnt/zfs/k8s-backup"
              "RESTIC_CACHE_DIR=/tmp/restic-cache"
              "NFS_MOUNT_PATH=/mnt/nfs"
              "SMTP_PASSWORD_FILE=${config.age.secrets.smtp-password.path}"
              # Needed to avoid considering all files changed for every new ZFS snapshot.
              # See https://forum.restic.net/t/backing-up-zfs-snapshots-good-idea/9604
              "RESTIC_FEATURES=device-id-for-hardlinks"
            ];
          };
        };
        timers.homelab-backup = {
          description = "Homelab backup";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "02:00";
            Persistent = true;
          };
        };
      };

    age.secrets = myLib.mkSecrets [
      "restic-password"
      "smtp-password"
    ];
  };
}
