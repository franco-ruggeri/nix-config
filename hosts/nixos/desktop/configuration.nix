{ config, ... }:
{
  networking.hostName = "ruggeri-desktop";

  myModules.system = {
    username = "franco";
    tui = {
      enable = true;
      kubernetes = {
        enable = true;
        server = config.networking.hostName;
      };
    };
    gui = {
      enable = true;
      gaming.enable = true;
    };
  };

  # DO NOT change! Used for backward compatibility.
  system.stateVersion = "25.05";
}
