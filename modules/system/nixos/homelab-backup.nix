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
  backupUser = cfg.user;
  backupHome = "/home/${backupUser}";
  backupDataset = "zfs/k8s-backup";
  zfsDatasets = [
    "k8s-nfs"
    "k8s-longhorn"
  ];

  homelabBackupPython = myLib.mkPythonPackage {
    derivationName = "homelab-backup-python";
    packageName = "homelab_backup";
  };
in
{
  options.myModules.system.homelab.backup = {
    enable = lib.mkEnableOption "Enable backups for homelab";
    user = lib.mkOption {
      type = lib.types.str;
      default = "k8s-backup";
      description = "User that runs backup jobs and owns ZFS backup permissions.";
    };
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
    sourceAuthorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "SSH public keys allowed to log into the backup user on source hosts.";
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
    ];

    users.users.${backupUser} = {
      isNormalUser = true;
      createHome = true;
      home = backupHome;
      shell = pkgs.bashInteractive;
      hashedPassword = "!";
      openssh.authorizedKeys.keys = lib.optionals (cfg.role == "source") cfg.sourceAuthorizedKeys;
    };

    environment.systemPackages = with pkgs; [
      restic
      python3
    ];

    system.activationScripts.homelabBackupZfsAllow.text =
      lib.optionalString (cfg.role == "source") ''
        ${pkgs.zfs}/bin/zfs set com.sun:auto-snapshot=false ${backupDataset}
        ${pkgs.zfs}/bin/zfs allow -u ${backupUser} send,snapshot,destroy,rename ${backupDataset}
      ''
      + lib.optionalString (cfg.role == "destination") ''
        ${pkgs.zfs}/bin/zfs set com.sun:auto-snapshot=false ${backupDataset}
        ${pkgs.zfs}/bin/zfs allow -u ${backupUser} receive,mount,create,destroy,rollback,rename ${backupDataset}
      '';

    systemd = {
      services =
        lib.optionalAttrs (cfg.role == "source") {
          homelab-backup-restic = {
            description = "Homelab backup restic on source";
            serviceConfig = {
              Type = "oneshot";
              User = backupUser;
              ExecStart = "${pkgs.python3}/bin/python -m homelab_backup restic";
              WorkingDirectory = homelabBackupPython;
              Environment = [
                "PATH=/run/current-system/sw/bin/:/usr/bin:/bin:/usr/sbin:/sbin"
                "PYTHONPATH=${homelabBackupPython}"
                "HOME=${backupHome}"
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
              User = backupUser;
              ExecStart = "${pkgs.python3}/bin/python -m homelab_backup zfs-pull";
              WorkingDirectory = homelabBackupPython;
              Environment = [
                "PATH=/run/current-system/sw/bin/:/usr/bin:/bin:/usr/sbin:/sbin"
                "PYTHONPATH=${homelabBackupPython}"
                "HOME=${backupHome}"
                "SOURCE_HOST=${cfg.sourceHost}"
                "SOURCE_USER=${backupUser}"
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
          owner = backupUser;
          group = backupUser;
        };
      }
      // lib.optionalAttrs (cfg.role == "source") {
        "restic-password" = resticSecret // {
          owner = backupUser;
          group = backupUser;
        };
      };
  };
}
