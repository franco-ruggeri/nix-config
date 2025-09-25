{
  pkgs,
  myLib,
  ...
}:
let
  gnomeTheme = "Adwaita-dark";
in
{
  imports = [
    ../common
    ../../../modules/user/linux
  ];

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
    configFile = myLib.mkConfigFiles ./config;
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
}
