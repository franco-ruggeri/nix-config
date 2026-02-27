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

    systemd = {
      services =
        let
          environment = [
            "PATH=/run/current-system/sw/bin/:/usr/bin:/bin:/usr/sbin:/sbin"
            "NFS_SERVER_ADDRESS=${config.myModules.system.homelab.nfs.client.serverAddress}"
            "RESTIC_PASSWORD_FILE=${config.age.secrets.restic-password.path}"
            "RESTIC_REPOSITORY=/mnt/zfs/k8s-backup"
            "RESTIC_CACHE_DIR=/tmp/restic-cache"
            "NFS_MOUNT_PATH=/mnt/nfs"
            "SMTP_PASSWORD_FILE=${config.age.secrets.smtp-password.path}"
          ];
          pythonScriptDir = myLib.mkPythonScriptDir {
            derivationName = "homelab_test_backup_daily";
            scriptNames = [
              "homelab_test_backup_daily.py"
              "homelab_test_backup_weekly.py"
              "homelab_test_backup_monthly.py"
              "homelab_test_backup_utils.py"
            ];
          };
        in
        {
          homelab-make-backup = {
            description = "Homelab make backup";
            serviceConfig = {
              Type = "oneshot";
              ExecStart = myLib.mkShellScript "homelab-make-backup.sh";
              Environment = environment;
            };
          };
          homelab-test-backup-daily = {
            description = "Homelab test backup daily";
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${pythonScriptDir}/homelab_test_backup_daily.py";
              Environment = environment;
            };
          };
          homelab-test-backup-weekly = {
            description = "Homelab test backup weekly";
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${pythonScriptDir}/homelab_test_backup_weekly.py";
              Environment = environment;
            };
          };
          homelab-test-backup-monthly = {
            description = "Homelab test backup monthly";
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${pythonScriptDir}/homelab_test_backup_monthly.py";
              Environment = environment;
            };
          };
        };
      timers = {
        homelab-make-backup = {
          description = "Homelab make backup";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "02:00";
            Persistent = true;
          };
        };
        homelab-test-backup-daily = {
          description = "Homelab test backup daily";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "01:00";
            Persistent = true;
          };
        };
        homelab-test-backup-weekly = {
          description = "Homelab test backup weekly";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "Mon *-*-* 01:00";
            Persistent = true;
          };
        };
        homelab-test-backup-monthly = {
          description = "Homelab test backup monthly";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "*-*-1 01:00";
            Persistent = true;
          };
        };
      };
    };

    age.secrets = myLib.mkSecrets [
      "restic-password"
      "smtp-password"
    ];
  };
}
