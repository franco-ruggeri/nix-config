{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
let
  cfg = config.myModules.home.homelab.backup.dst;
  homelabBackup = myLib.mkPythonApplication "homelab-backup";
in
{
  options.myModules.home.homelab.backup.dst = {
    enable = lib.mkEnableOption "Enable backup destination for homelab";
    srcHost = lib.mkOption {
      type = lib.types.str;
      description = "Source host reachable by the destination backup server.";
    };
    srcUser = lib.mkOption {
      type = lib.types.str;
      description = "User on the source host to connect as via SSH.";
    };
    resticRepositoryFile = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      restic
      rsync
    ];

    launchd.agents = {
      homelab-backup-dst = {
        enable = true;
        config = {
          Label = "org.nixos.homelab-backup-dst";
          # In EnvironmentVariables, the home-manager command to get the agenix path would not be expanded.
          # So we have to export the environment variables with agenix secrets in ProgramArguments.
          ProgramArguments = [
            "bash"
            "-c"
            ''
              export RESTIC_REPOSITORY_FILE=${cfg.resticRepositoryFile} && \
              export RESTIC_PASSWORD_FILE=${config.age.secrets.restic-password.path} && \
              export SMTP_PASSWORD_FILE=${config.age.secrets.smtp-password.path} && \
              ${homelabBackup}/bin/homelab-backup dst-rsync
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
            SRC_HOST = "${cfg.srcHost}";
            SRC_USER = "${cfg.srcUser}";
          };
          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/homelab-backup-dst/out.log";
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/homelab-backup-dst/error.log";
        };
      };
    };

    age.secrets = myLib.mkSecrets [
      "restic-password"
      "smtp-password"
    ];
  };
}
