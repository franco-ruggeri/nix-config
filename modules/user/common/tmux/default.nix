{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [ tmux ];

  xdg.configFile.tmux = {
    source = ./config;
    recursive = true;
  };
}
