{ lib, ... }:

{
  programs = { zsh.enable = true; };

  # TODO: I'm still relying on the external ~/.zshenv...
  xdg.configFile.zsh = {
    source = ./config;
    recursive = true;
  };
}
