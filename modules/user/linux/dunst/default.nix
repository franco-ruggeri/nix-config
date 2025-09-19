{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [ dunst ];

  xdg.configFile.dunst = {
    source = ./config;
    recursive = true;
  };
}
