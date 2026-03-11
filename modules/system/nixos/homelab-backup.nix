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
        assertion = config.myModules.system.homelab.wireguard.enable;
        message = "WireGuard client must be enabled for homelab backups.";
      }
      {
        assertion = config.myModules.system.homelab.nfs.client.enable;
        message = "NFS client must be enabled for homelab backups.";
      }
    ];

    environment.systemPackages = with pkgs; [
      restic
      python3
    ];

    systemd =
      let
        pythonScriptDir = myLib.mkPythonScriptDir {
          derivationName = "homelab_backup_restic";
          scriptNames = [
            "homelab_backup_restic.py"
            "homelab_backup_utils.py"
          ];
        };
      in
      {
        services.homelab-backup-restic = {
          description = "Homelab backup restic";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pythonScriptDir}/homelab_backup_restic.py";
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
            ExecStartPre = pkgs.writeShellScript "homelab-backup-restic-pre" ''
              echo "Waiting for WireGuard to be ready..."
              until wg show wg0 latest-handshakes | awk '{print $2}' | grep -qv '^0$'; do
                sleep 5
              done

              echo "Setting RTC wakealarm for tomorrow 2 AM..."
              echo 0 > /sys/class/rtc/rtc0/wakealarm
              date -d "tomorrow 02:00" +%s > /sys/class/rtc/rtc0/wakealarm
            '';
            ExecStartPost = pkgs.writeShellScript "homelab-backup-restic-post" ''
              echo "Shutting down in 10 seconds..."
              sleep 10
              systemctl poweroff
            '';
          };
        };
        timers.homelab-backup-restic = {
          description = "Homelab backup restic";
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
