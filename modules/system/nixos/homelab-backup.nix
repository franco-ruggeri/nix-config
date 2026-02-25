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
in
{
  options.myModules.system.homelab.backup.enable = lib.mkEnableOption "Enable backups for homelab";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.myModules.system.nfs.client.enable;
        message = "NFS client must be enabled for NFS backup.";
      }
    ];

    environment.systemPackages = with pkgs; [ restic ];

    systemd = {
      services.homelab-backup = {
        description = "Homelab backup";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = myLib.mkShellScript "homelab-backup.sh";
          Environment = [
            "PATH=/run/current-system/sw/bin/:/usr/bin:/bin:/usr/sbin:/sbin"
            "NFS_SERVER_ADDRESS=${config.myModules.system.nfs.client.serverAddress}"
            "RESTIC_PASSWORD_FILE=${config.age.secrets.restic-password.path}"
            "RESTIC_REPOSITORY=/mnt/zfs/k8s-backup"
            "RESTIC_CACHE_DIR=/tmp/restic-cache"
            "NFS_EXPORT_PATH=/mnt/nfs/k8s-backup"
          ];
        };
      };
      timers.homelab-backup = {
        description = "Homelab backup";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "02:00";
          Persistent = true;
        };
      };
    };

    age.secrets = myLib.mkSecrets [ "restic-password" ];
  };
}
