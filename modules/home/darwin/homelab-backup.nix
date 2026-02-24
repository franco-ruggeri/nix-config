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
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ restic ];

    launchd.agents.homelab-backup = {
      enable = true;
      config = {
        Label = "org.nixos.homelab-backup";
        # In EnvironmentVariables, the home-manager command to get the agenix path would not be expanded.
        # So we have to export the environment variables with agenix secrets in the command itself.
        ProgramArguments = [
          "bash"
          "-c"
          ''
            export RESTIC_REPOSITORY_FILE=${config.age.secrets.restic-repository-laptop.path} && \
            export RESTIC_PASSWORD_FILE=${config.age.secrets.restic-password.path} && \
            ${myLib.mkShellScript "homelab-backup.sh"}
          ''
        ];
        StartCalendarInterval = [
          {
            Hour = 14;
            Minute = 0;
          }
        ];
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/homelab-backup/out.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/homelab-backup/error.log";
        EnvironmentVariables = {
          PATH = "${config.home.homeDirectory}/.nix-profile/bin:/usr/bin:/bin:/usr/sbin:/sbin";
          NFS_MOUNT_POINT = "/Volumes/nfs";
          RESTIC_CACHE_DIR = "/tmp/restic-cache";
          # Needed to avoid considering all files changed for every new ZFS snapshot.
          # See https://forum.restic.net/t/backing-up-zfs-snapshots-good-idea/9604
          RESTIC_FEATURES = "device-id-for-hardlinks";
        };
      };
    };

    age.secrets = myLib.mkSecrets [
      "restic-repository-laptop"
      "restic-password"
    ];
  };
}
