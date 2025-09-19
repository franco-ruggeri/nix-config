{
  programs.ghostty.enable = true;

  xdg.configFile.ghostty = {
    source = ./config;
    recursive = true;
  };
}
