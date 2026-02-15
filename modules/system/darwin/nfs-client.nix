{
  config,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.system.nfs.client;
in
{
  config = lib.mkIf cfg.enable {
    launchd.daemons.nfs-mount = {
      serviceConfig = {
        Label = "org.nixos.nfs-mount";
        ProgramArguments = [
          "bash"
          "-c"
          ''
            ${myLib.mkShellScript "nfs-mount.sh"}
          ''
        ];
        RunAtLoad = true; # run at boot
        StartInterval = 300; # retry every 5 minutes
        StandardOutPath = "/var/log/nfs-mount/out.log";
        StandardErrorPath = "/var/log/nfs-mount/error.log";
        EnvironmentVariables = {
          NFS_SERVER_ADDRESS = cfg.serverAddress;
          NFS_MOUNT_POINT = "/Volumes/nfs";
        };
      };
    };
  };
}
