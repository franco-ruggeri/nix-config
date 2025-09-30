{
  config,
  pkgs,
  myLib,
  ...
}:
let
  gnomeTheme = "Adwaita-dark";
in
{
  imports = [ ../common ];

  home = {
    username = config.myModules.home.username;
    homeDirectory = /home/${config.myModules.home.username};

    packages = with pkgs; [
      dunst
      pamixer
      slurp
      grim
      nemo
      wl-clipboard
      whatsie
      kdePackages.okular
    ];
    file.".local" = {
      source = ./local;
      recursive = true;
    };
  };

  programs = {
    ghostty.enable = true;
    hyprlock.enable = true;
    waybar.enable = true;
    wofi.enable = true;
    thunderbird = {
      enable = true;
      profiles.default.isDefault = true;
    };
    obs-studio.enable = true;
    rclone = {
      enable = true;
      remotes = {
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
  };

  services = {
    hyprpaper.enable = true;
    hyprpolkitagent.enable = true;
    hypridle.enable = true;
    playerctld.enable = true;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = "$dummy = true"; # just to disable warning
  };

  xdg = {
    configFile = myLib.mkConfigDir ./config;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
    mimeApps.defaultApplications = {
      "inode/directory" = "nemo.desktop";
      "text/html" = "firefox.desktop";
      "image/svg+xml" = "org.inkscape.Inkscape.desktop";
      "video/mp4" = "mpv.desktop";
      "application/pdf" = "org.kde.okular.desktop";
      "application/x-extension-htm" = "firefox.desktop";
      "application/x-extension-html" = "firefox.desktop";
      "application/x-extension-shtml" = "firefox.desktop";
      "application/xhtml+xml" = "firefox.desktop";
      "application/x-extension-xhtml" = "firefox.desktop";
      "application/x-extension-xht" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/chrome" = "firefox.desktop";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = gnomeTheme;
      package = pkgs.gnome-themes-extra;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = gnomeTheme;
  };

  age.secrets = myLib.mkSecrets [
    "rclone-gdrive-personal-client-secret"
    "rclone-gdrive-personal-token"
    "rclone-gdrive-pianeta-costruzioni-client-secret"
    "rclone-gdrive-pianeta-costruzioni-token"
    "rclone-onedrive-kth-token"
  ];
}
