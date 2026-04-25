{ config, myLib, ... }:
{
  networking.hostName = "franco-ruggeri-server-turin";

  myModules.system = {
    username = "franco";
    hashedPasswordFile = config.age.secrets.user-password-server-turin.path;
    tui.enable = true;
    homelab = {
      wireguard = {
        enable = true;
        address = "10.34.0.5/24";
        privateKeyFile = config.age.secrets.wireguard-private-key-server-turin.path;
      };
      backup.enable = true;
    };
  };

  age.secrets =
    myLib.mkSecrets [ "user-password-server-turin" ]
    // myLib.mkWireguardSecrets [ "wireguard-private-key-server-turin" ];

  # DO NOT change! Used for backward compatibility.
  system.stateVersion = "25.05";
}
