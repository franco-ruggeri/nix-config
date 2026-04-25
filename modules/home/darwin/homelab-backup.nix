{
  config,
  pkgs,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.home.homelab.backup;
in
{
  options.myModules.home.homelab.backup = {
    enable = lib.mkEnableOption "Enable backups for homelab";
    serverAddress = lib.mkOption { type = lib.types.str; };
    resticRepositoryFile = lib.mkOption { type = lib.types.str; };
    rsyncPull = {
      enable = lib.mkEnableOption "Enable rsync pull backup from homelab source";
      sourceDataset = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      sourceUser = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      destinationPath = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.rsyncPull.enable || cfg.rsyncPull.sourceDataset != null;
        message = "homelab.backup.rsyncPull.sourceDataset must be set when rsyncPull is enabled.";
      }
      {
        assertion = !cfg.rsyncPull.enable || cfg.rsyncPull.sourceUser != null;
        message = "homelab.backup.rsyncPull.sourceUser must be set when rsyncPull is enabled.";
      }
      {
        assertion = !cfg.rsyncPull.enable || cfg.rsyncPull.destinationPath != null;
        message = "homelab.backup.rsyncPull.destinationPath must be set when rsyncPull is enabled.";
      }
    ];

    home.packages = with pkgs; [
      restic
      rsync
    ];

    launchd.agents =
      let
        homelabBackupPython = myLib.mkPythonPackage {
          derivationName = "homelab-backup-python";
          packageName = "homelab_backup";
        };
      in
      {
        homelab-backup-restic = {
          enable = true;
          config = {
            Label = "org.nixos.homelab-backup-restic";
            # In EnvironmentVariables, the home-manager command to get the agenix path would not be expanded.
            # So we have to export the environment variables with agenix secrets in ProgramArguments.
            ProgramArguments = [
              "bash"
              "-c"
              ''
                export RESTIC_REPOSITORY_FILE=${cfg.resticRepositoryFile} && \
                export RESTIC_PASSWORD_FILE=${config.age.secrets.restic-password.path} && \
                export SMTP_PASSWORD_FILE=${config.age.secrets.smtp-password.path} && \
                export PYTHONPATH=${homelabBackupPython} && \
                ${pkgs.python3}/bin/python -m homelab_backup restic
              ''
            ];
            StartCalendarInterval = [
              {
                Hour = 14;
                Minute = 0;
              }
            ];
            EnvironmentVariables = {
              PATH = "${config.home.homeDirectory}/.nix-profile/bin:/usr/bin:/bin:/usr/sbin:/sbin";
              NFS_MOUNT_PATH = "/Volumes/nfs";
              RESTIC_CACHE_DIR = "/tmp/restic-cache";
              # Needed to avoid considering all files changed for every new ZFS snapshot.
              # See https://forum.restic.net/t/backing-up-zfs-snapshots-good-idea/9604
              RESTIC_FEATURES = "device-id-for-hardlinks";
            };
            StandardOutPath = "${config.home.homeDirectory}/Library/Logs/homelab-backup-restic/out.log";
            StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/homelab-backup-restic/error.log";
          };
        };
      }
      // lib.optionalAttrs cfg.rsyncPull.enable {
        homelab-backup-rsync-pull =
          let
            homelabBackupPython = myLib.mkPythonPackage {
              derivationName = "homelab-backup-python";
              packageName = "homelab_backup";
            };
          in
          {
            enable = true;
            config = {
              Label = "org.nixos.homelab-backup-rsync-pull";
              ProgramArguments = [
                "bash"
                "-c"
                ''
                  export SOURCE_HOST=${cfg.serverAddress} && \
                  export SOURCE_USER=${cfg.rsyncPull.sourceUser} && \
                  export SOURCE_DATASET=${cfg.rsyncPull.sourceDataset} && \
                  export RSYNC_DEST_PATH=${cfg.rsyncPull.destinationPath} && \
                  export SMTP_PASSWORD_FILE=${config.age.secrets.smtp-password.path} && \
                  export PYTHONPATH=${homelabBackupPython} && \
                  ${pkgs.python3}/bin/python -m homelab_backup rsync-pull
                ''
              ];
              StartCalendarInterval = [
                {
                  Hour = 15;
                  Minute = 0;
                }
              ];
              EnvironmentVariables = {
                PATH = "${config.home.homeDirectory}/.nix-profile/bin:/usr/bin:/bin:/usr/sbin:/sbin";
              };
              StandardOutPath = "${config.home.homeDirectory}/Library/Logs/homelab-backup-rsync-pull/out.log";
              StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/homelab-backup-rsync-pull/error.log";
            };
          };
      };

    age.secrets = myLib.mkSecrets [
      "restic-password"
      "smtp-password"
    ];
  };
}
