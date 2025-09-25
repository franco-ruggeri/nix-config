{ pkgs, myLib, ... }:
let
  gnomeTheme = "Adwaita-dark";
in
{
  imports = [
    ../common
    ../../../modules/user/linux
  ];

  home.packages = with pkgs; [
    dunst
    pamixer
    slurp
    grim
    wl-clipboard
    whatsie
  ];

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
    #hypridle.enable = true;
    playerctld.enable = true;
  };

  wayland.windowManager.hyprland.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
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

  xdg.configFile = myLib.mkConfigFiles ./config;
}
