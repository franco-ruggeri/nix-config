# Assumptions:
# - A ZFS dataset named zfs/k8s-backup exists with mountpoint=/mnt/zfs/k8s-backup.
# - Root on this host can SSH into sourceHost as sourceUser without a password.
{
  config,
  pkgs,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.system.homelab.backupDst;
  homelabBackup = myLib.mkPythonApplication "homelab-backup";
in
{
  options.myModules.system.homelab.backupDst = {
    enable = lib.mkEnableOption "Enable backup destination for homelab";
    sourceHost = lib.mkOption {
      type = lib.types.str;
      description = "Source host reachable by the destination backup server.";
    };
    sourceUser = lib.mkOption {
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
          ExecStart = "${homelabBackup}/bin/homelab-backup dst --mode zfs";
          Environment = [
            "PATH=/run/current-system/sw/bin/:/usr/bin:/bin:/usr/sbin:/sbin"
            "SOURCE_HOST=${cfg.sourceHost}"
            "SOURCE_USER=${cfg.sourceUser}"
            "SMTP_PASSWORD_FILE=${config.age.secrets.smtp-password.path}"
          ];
          ExecStartPre = pkgs.writeShellScript "homelab-backup-zfs-pull-pre" ''
            echo "Waiting for WireGuard to be ready..."
            until wg show wg0 latest-handshakes | awk '{print $2}' | grep -qv '^0$'; do
              sleep 5
            done
          '';
        };
      };
      timers.homelab-backup-dst = {
        description = "Homelab backup destination";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "03:00";
          Persistent = true;
        };
      };
    };

    age.secrets = myLib.mkSecrets [ "smtp-password" ];
  };
}
