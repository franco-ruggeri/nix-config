{ config, lib, ... }:
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

    # TODO: implement a systemd service + timer for calling nfs-backup.sh. See darwin version for reference.
  };
}
