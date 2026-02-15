{ config, lib, ... }:
let
  cfg = config.myModules.system.nfs.backup;
in
{
  config = lib.mkIf cfg.enable {
    # TODO: implement a systemd service + timer for calling nfs-backup.sh. See darwin version for reference.
  };
}
