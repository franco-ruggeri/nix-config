{
  lib,
  myLib,
  config,
  ...
}:
let
  cfg = config.myModules.home.cloud;
  vfsCacheMaxSize = "10G";
in
{
  options.myModules.home.cloud.enable = lib.mkEnableOption "Enables mounts of cloud storage services";

  config = lib.mkIf cfg.enable {
    programs.rclone = {
      enable = true;
      remotes = {
        nextcloud = {
          config = rec {
            type = "webdav";
            user = "franco-ruggeri";
            url = "https://www.nextcloud.francoruggeri.dev/remote.php/dav/files/${user}";
            vendor = "nextcloud";
          };
          secrets = {
            pass = config.age.secrets.rclone-nextcloud-password.path;
          };
          mounts."/" = {
            enable = true;
            mountPoint = "${config.home.homeDirectory}/drives/nextcloud";
            options = {
              vfs-cache-max-size = vfsCacheMaxSize;
            };
          };
        };
        gdrive-pianeta-costruzioni = {
          config = {
            type = "drive";
            scope = "drive";
            client_id = "713359081237-lc5kl31ce7utens0blql5m39euel8936.apps.googleusercontent.com";
          };
          secrets = {
            client_secret = config.age.secrets.rclone-gdrive-pianeta-costruzioni-client-secret.path;
            token = config.age.secrets.rclone-gdrive-pianeta-costruzioni-token.path;
          };
          mounts."/" = {
            enable = true;
            mountPoint = "${config.home.homeDirectory}/drives/gdrive-pianeta-costruzioni";
            options = {
              vfs-cache-max-size = vfsCacheMaxSize;
            };
          };
        };
      };
    };

    age.secrets = myLib.mkSecrets [
      "rclone-nextcloud-password"
      "rclone-gdrive-pianeta-costruzioni-client-secret"
      "rclone-gdrive-pianeta-costruzioni-token"
    ];
  };
}
