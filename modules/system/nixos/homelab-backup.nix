# Assumptions:
# - A ZFS dataset named zfs/k8s-backup exists with mountpoint=/mnt/zfs/k8s-backup.
# - The ZFS dataset named zfs/k8s-backup has ZFS send/receive delegations granted to the main user.
{
  config,
  pkgs,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.system.homelab.backup;
  mainUser = config.myModules.system.username;
  mainHome = "/home/${mainUser}";
  backupDataset = "zfs/k8s-backup";
  zfsDatasets = [
    "zfs/k8s-nfs"
    "zfs/k8s-longhorn"
  ];
  homelabBackup = myLib.mkPythonApplication "homelab-backup";
in
{
  options.myModules.system.homelab.backup = {
    enable = lib.mkEnableOption "Enable backups for homelab";
    role = lib.mkOption {
      type = lib.types.enum [
        "source"
        "destination"
      ];
    };
    sourceHost = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Source host reachable by the destination backup server.";
    };
    sshPrivateKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "SSH private key file used by destination to authenticate to source.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.myModules.system.homelab.wireguard.enable;
        message = "WireGuard client must be enabled for homelab backups.";
      }
      {
        assertion = config.myModules.system.zfs.enable;
        message = "ZFS must be enabled for homelab backups.";
      }
      {
        assertion = cfg.role != "destination" || cfg.sourceHost != null;
        message = "A sourceHost must be set for destination backups.";
      }
      {
        assertion = cfg.role != "source" || config.myModules.system.homelab.nfs.enable;
        message = "NFS server must be enabled on the backup source host.";
      }
    ];

    environment.systemPackages = with pkgs; [
      restic
    ];

    systemd = {
      services =
        lib.optionalAttrs (cfg.role == "source") {
          homelab-backup-restic = {
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
        }
        // lib.optionalAttrs (cfg.role == "destination") {
          homelab-backup-zfs-pull = {
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
                "SOURCE_DATASET=${backupDataset}"
                "DEST_DATASET=${backupDataset}"
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
        };

      timers =
        lib.optionalAttrs (cfg.role == "source") {
          homelab-backup-restic = {
            description = "Homelab backup restic on source";
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnCalendar = "02:00";
              Persistent = true;
            };
          };
        }
        // lib.optionalAttrs (cfg.role == "destination") {
          homelab-backup-zfs-pull = {
            description = "Homelab backup ZFS pull on destination";
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnCalendar = "03:00";
              Persistent = true;
            };
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
      }
      // lib.optionalAttrs (cfg.role == "source") {
        "restic-password" = resticSecret // {
          owner = mainUser;
          group = mainUser;
        };
      };
  };
}
