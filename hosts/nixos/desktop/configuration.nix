{ config, myLib, ... }:
{
  networking.hostName = "ruggeri-desktop";

  myModules.system = {
    username = "franco";
    tui.enable = true;
    gui.enable = true;
    gaming.enable = true;
    kubernetes = {
      enable = true;
      server = config.networking.hostName;
    };
    wireguard = {
      enable = true;
      address = "10.34.0.2/24";
      privateKeyFile = config.age.secrets.wireguard-desktop-private-key.path;
      presharedKeyFile = config.age.secrets.wireguard-desktop-preshared-key.path;
    };
  };

  age.secrets = myLib.mkWireguardSecrets [
    "wireguard-desktop-private-key"
    "wireguard-desktop-preshared-key"
  ];

  # DO NOT change! Used for backward compatibility.
  system.stateVersion = "25.05";
}
