{ pkgs, ... }:
{
  myModules.home = {
    username = "ubuntu";
    tui.enable = true;
  };

  home.packages = with pkgs; [ openclaw ];

  # DO NOT change! Used for backward compatibility.
  home.stateVersion = "25.05";
}
