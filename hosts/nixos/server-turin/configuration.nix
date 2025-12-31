{ config, myLib, ... }:
{
  networking.hostName = "franco-ruggeri-server-turin";

  myModules.system = {
    username = "franco";
    tui.enable = true;
    wireguard = {
      enable = true;
      address = "10.34.0.5/24";
      privateKeyFile = config.age.secrets.wireguard-server-turin-private-key.path;
    };
  };

  age.secrets = myLib.mkWireguardSecrets [
    "wireguard-server-turin-private-key"
  ];

  # DO NOT change! Used for backward compatibility.
  system.stateVersion = "25.05";
}
