{ pkgs, ... }:

{
  users.users = {
    franco-ruggeri = {
      extraGroups = [ "wheel" "networkmanager" "docker" ];
      shell = pkgs.zsh;
    };
    roberta-salmeri = { isNormalUser = true; };
  };

  home-manager.users = {
    franco-ruggeri = {
      aichat.enable = true;
      ghostty.enable = true;
      git.enable = true;
      neovim.enable = true;
      tmux.enable = true;
      zsh.enable = true;
      dunst.enable = true;
      hyprland.enable = true;
      waybar.enable = true;
      wofi.enable = true;
    };
    roberta-salmeri = { };
  };

  # DO NOT change! Used for backward compatibility.
  home-manager.users.franco-ruggeri.home.stateVersion = "25.05";
}
