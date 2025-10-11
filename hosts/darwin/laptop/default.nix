{ config, myLib, ... }:
{
  myModules.system = {
    username = "erugfra";
    tui.enable = true;
    gui.enable = true;
    wireguard = {
      enable = true;
      address = "10.34.0.3/32";
      privateKeyFile = config.age.secrets.wireguard-laptop-private-key.path;
      presharedKeyFile = config.age.secrets.wireguard-laptop-preshared-key.path;
    };
  };

  age.secrets = myLib.mkWireguardSecrets [
    "wireguard-laptop-private-key"
    "wireguard-laptop-preshared-key"
  ];

  # DO NOT change! Used for backward compatibility.
  system.stateVersion = 6;
}
