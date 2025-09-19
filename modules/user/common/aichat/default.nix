{ pkgs, ... }:

{
  home.packages = with pkgs; [ aichat ];

  xdg.configFile.aichat = {
    source = ./config;
    recursive = true;
  };
}
