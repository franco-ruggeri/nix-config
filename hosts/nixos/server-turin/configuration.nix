{ config, myLib, ... }:
{
  networking.hostName = "franco-ruggeri-server-turin";

  myModules.system = {
    username = "franco";
    tui.enable = true;
    homelab = {
      wireguard = {
        enable = true;
        address = "10.34.0.5/24";
        privateKeyFile = config.age.secrets.wireguard-private-key-server-turin.path;
      };
      nfs = {
        client = {
          enable = true;
          serverAddress = "10.34.0.2";
        };
      };
      backup.enable = true;
    };
  };

  age.secrets = myLib.mkWireguardSecrets [
    "wireguard-private-key-server-turin"
  ];

  # DO NOT change! Used for backward compatibility.
  system.stateVersion = "25.05";
}
