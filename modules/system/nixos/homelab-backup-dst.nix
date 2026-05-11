# Assumptions:
# - The ZFS dataset zfs/k8s-backup exists with mountpoint /mnt/zfs/k8s-backup.
# - Root on this host can SSH into srcHost as srcUser without a password.
{
  config,
  pkgs,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.system.homelab.backup.dst;
  homelabBackup = myLib.mkPythonApplication "homelab-backup";
in
{
  options.myModules.system.homelab.backup.dst = {
    enable = lib.mkEnableOption "Enable backup destination for homelab";
    srcHost = lib.mkOption {
      type = lib.types.str;
      description = "Source host reachable by the destination backup server.";
    };
    srcUser = lib.mkOption {
      type = lib.types.str;
      description = "User on the source host to connect as via SSH.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.myModules.system.homelab.wireguard.enable;
        message = "WireGuard client must be enabled for homelab backup destination.";
      }
      {
        assertion = config.myModules.system.zfs.enable;
        message = "ZFS must be enabled for homelab backup destination.";
      }
    ];

    systemd = {
      services.homelab-backup-dst = {
        description = "Homelab backup destination";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${homelabBackup}/bin/homelab-backup dst-zfs";
          Environment = [
            "PATH=/run/current-system/sw/bin/:/usr/bin:/bin:/usr/sbin:/sbin"
            "SRC_HOST=${cfg.srcHost}"
            "SRC_USER=${cfg.srcUser}"
            "RESTIC_PASSWORD_FILE=${config.age.secrets.restic-password.path}"
            "SMTP_PASSWORD_FILE=${config.age.secrets.smtp-password.path}"
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
      timers.homelab-backup-dst = {
        description = "Homelab backup destination";
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
