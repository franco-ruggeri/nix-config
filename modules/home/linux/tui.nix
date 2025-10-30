{
  config,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.home.tui;
in
{
  config = lib.mkIf (myLib.isLinux && cfg.enable) {
    programs.rclone = {
      enable = true;
      remotes = {
        nextcloud = {
          config = rec {
            type = "webdav";
            user = "franco-ruggeri";
            url = "https://www.nextcloud.ruggeri.ddnsfree.com/remote.php/dav/files/${user}";
            vendor = "nextcloud";
            vfs_cache_mode = "writes";
          };
          secrets = {
            pass = config.age.secrets.rclone-nextcloud-password.path;
          };
          mounts."/" = {
            enable = true;
            mountPoint = "${config.home.homeDirectory}/drives/nextcloud";
          };
        };
        gdrive-personal = {
          config = {
            type = "drive";
            scope = "drive";
            client_id = "985888792063-bej879uqfvj192se3bueif6kb2djg3ta.apps.googleusercontent.com";
          };
          secrets = {
            client_secret = config.age.secrets.rclone-gdrive-personal-client-secret.path;
            token = config.age.secrets.rclone-gdrive-personal-token.path;
          };
          mounts."/" = {
            enable = true;
            mountPoint = "${config.home.homeDirectory}/drives/gdrive-personal";
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
          };
        };
        onedrive-kth = {
          config = {
            type = "onedrive";
            drive_type = "business";
            drive_id = "b!4GWf6C2me0m5VC55iKz8_tfjB2clgiFDoKvDM9GYp_zttnyXpLE7R4uiD44KSQH_";
          };
          secrets = {
            token = config.age.secrets.rclone-onedrive-kth-token.path;
          };
          mounts."/" = {
            enable = true;
            mountPoint = "${config.home.homeDirectory}/drives/onedrive-kth";
          };
        };
      };
    };

    age.secrets = myLib.mkSecrets [
      "rclone-nextcloud-password"
      "rclone-gdrive-personal-client-secret"
      "rclone-gdrive-personal-token"
      "rclone-gdrive-pianeta-costruzioni-client-secret"
      "rclone-gdrive-pianeta-costruzioni-token"
      "rclone-onedrive-kth-token"
    ];
  };
}
