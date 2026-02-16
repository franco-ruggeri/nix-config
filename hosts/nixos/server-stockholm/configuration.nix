{ config, myLib, ... }:
{
  networking.hostName = "franco-ruggeri-server-stockholm";

  myModules.system = {
    username = "franco";
    tui.enable = true;
    wireguard = {
      enable = true;
      address = "10.34.0.6/24";
      privateKeyFile = config.age.secrets.wireguard-private-key-server-stockholm.path;
    };
    zfs.enable = true;
    nfs = {
      client = {
        enable = true;
        serverAddress = "10.34.0.2";
      };
      backup.enable = true;
    };
  };

  age.secrets = myLib.mkWireguardSecrets [
    "wireguard-private-key-server-stockholm"
  ];

  # DO NOT change! Used for backward compatibility.
  system.stateVersion = "25.05";
}
