{
  config,
  pkgs,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.home.nfs.backup;
in
{
  options.myModules.home.nfs.backup = {
    enable = lib.mkEnableOption "Enable NFS backup for home";
    serverAddress = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ restic ];

    launchd.agents.nfs-backup = {
      enable = true;
      config = {
        Label = "org.nixos.nfs-backup";
        # In EnvironmentVariables, the home-manager command to get the agenix path would not be expanded.
        # So we have to export the environment variables with agenix secrets in the command itself.
        ProgramArguments = [
          "bash"
          "-c"
          ''
            export RESTIC_REPOSITORY_FILE=${config.age.secrets.restic-repository-laptop.path} && \
            export RESTIC_PASSWORD_FILE=${config.age.secrets.restic-password.path} && \
            ${myLib.mkShellScript "nfs-backup.sh"}
          ''
        ];
        StartCalendarInterval = [
          {
            Hour = 17;
            Minute = 0;
          }
        ];
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/nfs-backup/out.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/nfs-backup/error.log";
        EnvironmentVariables = {
          PATH = "${config.home.homeDirectory}/.nix-profile/bin:/usr/bin:/bin:/usr/sbin:/sbin";
          NFS_SERVER_ADDRESS = cfg.serverAddress;
          NFS_MOUNT_POINT = "/Volumes/nfs";
          RESTIC_CACHE_DIR = "/tmp/restic-cache";
        };
      };
    };

    age.secrets = myLib.mkSecrets [
      "restic-repository-laptop"
      "restic-password"
    ];
  };
}
