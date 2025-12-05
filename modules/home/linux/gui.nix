{
  config,
  pkgs,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.home.gui;
in
{
  config = lib.mkIf (myLib.isLinux && cfg.enable) {
    home = {
      packages = with pkgs; [
        dunst
        pamixer
        slurp
        grim
        nemo
        wl-clipboard
        whatsie
        kdePackages.okular
        polychromatic
        shotcut
      ];

      pointerCursor = {
        enable = true;
        name = "Adwaita";
        package = pkgs.gnome-themes-extra;
        size = 24;
        gtk.enable = true;
        hyprcursor.enable = true;
      };

      file = myLib.mkLocalDotfiles [
        "share/hypr"
      ];
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
    };

    services = {
      hyprpaper.enable = true;
      hyprpolkitagent.enable = true;
      hypridle.enable = true;
      playerctld.enable = true;
    };

    xdg = {
      configFile = myLib.mkConfigDotfiles [
        "dunst"
        "hypr"
        "pipewire"
        "waybar"
        "wofi"
      ];
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

    wayland.windowManager.hyprland = {
      enable = true;
      extraConfig = "$dummy = true"; # just to disable warning
    };

    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "adwaita";
      style.name = "Adwaita-dark";
    };
  };
}
