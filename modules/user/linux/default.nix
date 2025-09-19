{ pkgs, ... }:

{
  imports = [ ./hyprland ./dunst ./waybar ./wofi ];

  home.packages = with pkgs; [
    whatsie
    pamixer
    wofi
    slurp
    grim
    wl-clipboard
    adwaita-icon-theme
    nemo
  ];

  # TODO: configure profiles
  programs.thunderbird = {
    enable = true;
    profiles.default = { isDefault = true; };
  };
}
