{
  config,
  pkgs,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.home.homelab.backup;
  nfs_mount_path = "/Volumes/nfs";
in
{
  options.myModules.home.homelab.backup = {
    enable = lib.mkEnableOption "Enable backups for homelab";
    serverAddress = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ restic ];

    # In EnvironmentVariables, the home-manager command to get the agenix path would not be expanded.
    # So we have to export the environment variables with agenix secrets in ProgramArguments.
    launchd.agents = {
      homelab-make-backup = {
        enable = true;
        config = {
          Label = "org.nixos.homelab-make-backup";
          # TODO: define the exported vars in a variable to avoid repeating in every unit
          ProgramArguments = [
            "bash"
            "-c"
            ''
              export RESTIC_REPOSITORY_FILE=${config.age.secrets.restic-repository-laptop.path} && \
              export RESTIC_PASSWORD_FILE=${config.age.secrets.restic-password.path} && \
              ${myLib.mkShellScript "homelab-make-backup.sh"}
            ''
          ];
          StartCalendarInterval = [
            {
              Hour = 14;
              Minute = 0;
            }
          ];
          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/homelab-make-backup/out.log";
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/homelab-make-backup/error.log";
          EnvironmentVariables = {
            PATH = "${config.home.homeDirectory}/.nix-profile/bin:/usr/bin:/bin:/usr/sbin:/sbin";
            NFS_MOUNT_PATH = nfs_mount_path;
            RESTIC_CACHE_DIR = "/tmp/restic-cache";
            # Needed to avoid considering all files changed for every new ZFS snapshot.
            # See https://forum.restic.net/t/backing-up-zfs-snapshots-good-idea/9604
            RESTIC_FEATURES = "device-id-for-hardlinks";
          };
        };
      };
      homelab-test-backup-daily = {
        enable = true;
        config =
          let
            scriptDir = myLib.mkPythonScripts {
              derivationName = "homelab_test_backup_daily";
              scriptNames = [
                "homelab_test_backup_daily.py"
                "homelab_test_backup_utils.py"
              ];
            };
            scriptPath = "${scriptDir}/homelab_test_backup_daily.py";
          in
          {
            Label = "org.nixos.homelab-test-backup-daily";
            ProgramArguments = [
              "bash"
              "-c"
              ''
                export RESTIC_REPOSITORY_FILE=${config.age.secrets.restic-repository-laptop.path} && \
                export RESTIC_PASSWORD_FILE=${config.age.secrets.restic-password.path} && \
                export SMTP_PASSWORD_FILE=${config.age.secrets.smtp-password.path} && \
                ${scriptPath}
              ''
            ];
            StartCalendarInterval = [
              {
                Hour = 14;
                Minute = 0;
              }
            ];
            StandardOutPath = "${config.home.homeDirectory}/Library/Logs/homelab-test-backup-daily/out.log";
            StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/homelab-test-backup-daily/error.log";
            EnvironmentVariables = {
              PATH = "${config.home.homeDirectory}/.nix-profile/bin:/usr/bin:/bin:/usr/sbin:/sbin";
              NFS_MOUNT_PATH = nfs_mount_path;
            };
          };
      };
    };

    age.secrets = myLib.mkSecrets [
      "restic-repository-laptop"
      "restic-password"
      "smtp-password"
    ];
  };
}
