# Assumption: A ZFS dataset named zfs/k8s-backup exists with mountpoint=/mnt/zfs/k8s-backup.
{
  config,
  pkgs,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.system.homelab.backupDst;
  mainUser = config.myModules.system.username;
  mainHome = "/home/${mainUser}";
  homelabBackup = myLib.mkPythonApplication "homelab-backup";
in
{
  options.myModules.system.homelab.backupDst = {
    enable = lib.mkEnableOption "Enable backup destination for homelab";
    sourceHost = lib.mkOption {
      type = lib.types.str;
      description = "Source host reachable by the destination backup server.";
    };
    sshPrivateKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "SSH private key file used to authenticate to source.";
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
      services.homelab-backup-zfs-pull = {
        description = "Homelab backup ZFS pull on destination";
        serviceConfig = {
          Type = "oneshot";
          User = mainUser;
          ExecStart = "${homelabBackup}/bin/homelab-backup zfs-pull";
          Environment = [
            "PATH=/run/current-system/sw/bin/:/usr/bin:/bin:/usr/sbin:/sbin"
            "HOME=${mainHome}"
            "SOURCE_HOST=${cfg.sourceHost}"
            "SOURCE_USER=${mainUser}"
            "SMTP_PASSWORD_FILE=${config.age.secrets.smtp-password.path}"
          ]
          ++ lib.optionals (cfg.sshPrivateKeyFile != null) [
            "SSH_PRIVATE_KEY_FILE=${cfg.sshPrivateKeyFile}"
          ];
          ExecStartPre = pkgs.writeShellScript "homelab-backup-zfs-pull-pre" ''
            echo "Waiting for WireGuard to be ready..."
            until wg show wg0 latest-handshakes | awk '{print $2}' | grep -qv '^0$'; do
              sleep 5
            done
          '';
        };
      };

      timers.homelab-backup-zfs-pull = {
        description = "Homelab backup ZFS pull on destination";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "03:00";
          Persistent = true;
        };
      };
    };

    age.secrets =
      let
        smtpSecret = (myLib.mkSecrets [ "smtp-password" ])."smtp-password";
      in
      {
        "smtp-password" = smtpSecret // {
          owner = mainUser;
          group = mainUser;
        };
      };
  };
}
