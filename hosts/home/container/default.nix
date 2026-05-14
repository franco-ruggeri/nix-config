{ pkgs, ... }:
{
  myModules.home = {
    username = "ubuntu";
    tui.enable = true;
  };

  # Add OpenClaw only in container. Deployed in a heavily sandboxed environment.
  home.packages = with pkgs; [ openclaw ];

  # DO NOT change! Used for backward compatibility.
  home.stateVersion = "25.05";
}
