# TODO: are the exec-once actually dependencies? how should I handle them? check ryan's config
{
  programs.hyprlock.enable = true;

  services = {
    hyprpaper.enable = true;
    hyprpolkitagent.enable = true;
  };

  wayland.windowManager.hyprland.enable = true;

  xdg.configFile.hypr = {
    source = ./config;
    recursive = true;
  };
}
