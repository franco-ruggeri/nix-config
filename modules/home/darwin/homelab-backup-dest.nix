{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
let
  cfg = config.myModules.home.homelab.backup.dest;
  homelabBackup = myLib.mkPythonApplication "homelab-backup";
in
{
  options.myModules.home.homelab.backup.dest = {
    enable = lib.mkEnableOption "Enable backup destination for homelab";
    sourceHost = lib.mkOption {
      type = lib.types.str;
      description = "Source host reachable by the destination backup server.";
    };
    sourceUser = lib.mkOption {
      type = lib.types.str;
      description = "User on the source host to connect as via SSH.";
    };
    resticRepositoryFile = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.myModules.system.homelab.wireguard.enable;
        message = "WireGuard client must be enabled for homelab backup destination.";
      }
    ];

    home.packages = with pkgs; [
      restic
      rsync
    ];

    launchd.agents = {
      homelab-backup-dest = {
        enable = true;
        config = {
          Label = "org.nixos.homelab-backup-dest";
          # In EnvironmentVariables, the home-manager command to get the agenix path would not be expanded.
          # So we have to export the environment variables with agenix secrets in ProgramArguments.
          ProgramArguments = [
            "bash"
            "-c"
            ''
              export RESTIC_REPOSITORY_FILE=${cfg.resticRepositoryFile} && \
              export RESTIC_PASSWORD_FILE=${config.age.secrets.restic-password.path} && \
              export SMTP_PASSWORD_FILE=${config.age.secrets.smtp-password.path} && \
              export SOURCE_HOST=${cfg.sourceHost} && \
              export SOURCE_USER=${cfg.sourceUser} && \
              ${homelabBackup}/bin/homelab-backup dest-rsync
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
          };
          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/homelab-backup-dest/out.log";
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/homelab-backup-dest/error.log";
        };
      };
    };

    age.secrets = myLib.mkSecrets [
      "restic-password"
      "smtp-password"
    ];
  };
}
