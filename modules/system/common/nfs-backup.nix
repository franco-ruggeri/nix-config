{
  pkgs,
  lib,
  myLib,
  ...
}:
{
  options.myModules.system.nfs.backup = {
    enable = lib.mkEnableOption "Enable NFS backup for homelab";
    serverAddress = lib.mkOption { type = lib.types.str; };
  };

  config = {
    environment.systemPackages = with pkgs; [ restic ];

    age.secrets = myLib.mkSecrets [ "restic-password" ];
  };
}
