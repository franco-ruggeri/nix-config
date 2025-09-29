{ config, ... }:
{
  imports = [ ../../modules/system/nixos ];

  networking.hostName = "ruggeri-desktop";

  myModules.system = {
    username = "franco";
    kubernetes = {
      enable = true;
      server = config.networking.hostName;
    };
    gaming.enable = true;
  };

  # DO NOT change! Used for backward compatibility.
  system.stateVersion = "25.05";
}
