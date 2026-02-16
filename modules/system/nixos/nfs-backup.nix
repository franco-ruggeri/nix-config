{
  config,
  pkgs,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.system.nfs.backup;
in
{
  options.myModules.system.nfs.backup.enable = lib.mkEnableOption "Enable NFS backup for homelab";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.myModules.system.nfs.client.enable;
        message = "NFS client must be enabled for NFS backup.";
      }
    ];

    environment.systemPackages = with pkgs; [ restic ];

    systemd = {
      services.nfs-backup = {
        description = "NFS backup service";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = myLib.mkShellScript "nfs-backup.sh";
          Environment = [
            "PATH=/run/current-system/sw/bin/:/usr/bin:/bin:/usr/sbin:/sbin"
            "RESTIC_PASSWORD_FILE=${config.age.secrets.restic-password.path}"
            "NFS_SERVER_ADDRESS=${config.myModules.system.nfs.client.serverAddress}"
            "RESTIC_REPOSITORY=/mnt/zfs/k8s-backup"
            "NFS_MOUNT_POINT=/mnt/nfs"
          ];
        };
      };
      timers.nfs-backup = {
        description = "NFS backup timer";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "23:00";
          Persistent = true;
        };
      };
    };

    age.secrets = myLib.mkSecrets [ "restic-password" ];
  };
}
