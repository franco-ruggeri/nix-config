# Assumptions:
# - The ZFS dataset zfs/k8s-backup exists with mountpoint /mnt/zfs/k8s-backup.
# - The main user is allowed to create,destroy,mount,rename,send,snapshot the ZFS dataset zfs/k8s-backup.
{
  config,
  pkgs,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.system.homelab.backup.src;
  homelabBackup = myLib.mkPythonApplication "homelab-backup";
  group = "homelab-backup";
in
{
  options.myModules.system.homelab.backup.src.enable =
    lib.mkEnableOption "Enable backup source for homelab";

  config = lib.mkIf cfg.enable {
    users = {
      groups.${group} = { };
      users.${config.myModules.system.username}.extraGroups = [ group ];
    };

    assertions = [
      {
        assertion = config.myModules.system.zfs.enable;
        message = "ZFS must be enabled for homelab backup source.";
      }
      {
        assertion = config.myModules.system.homelab.nfs.enable;
        message = "NFS server must be enabled on the backup source host.";
      }
    ];

    environment.systemPackages = with pkgs; [ restic ];

    systemd = {
      services.homelab-backup-src = {
        description = "Homelab backup source";
        serviceConfig = {
          Type = "oneshot";
          UMask = "0027";
          Group = group;
          ExecStart = "${homelabBackup}/bin/homelab-backup src";
          Environment = [
            "PATH=/run/current-system/sw/bin/:/usr/bin:/bin:/usr/sbin:/sbin"
            "RESTIC_PASSWORD_FILE=${config.age.secrets.restic-password.path}"
            "SMTP_PASSWORD_FILE=${config.age.secrets.smtp-password.path}"
          ];
        };
      };
      timers.homelab-backup-src = {
        description = "Homelab backup source";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "02:00";
          Persistent = true;
        };
      };
    };

    age.secrets = myLib.mkSecrets [
      "smtp-password"
      "restic-password"
    ];
  };
}
