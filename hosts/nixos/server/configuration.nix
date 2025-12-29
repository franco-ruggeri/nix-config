{ config, myLib, ... }:
{
  networking.hostName = "franco-ruggeri-server";

  myModules.system = {
    username = "franco";
    tui.enable = true;
    # TODO: need to enable this, but first I need to update the IP addresses so that tousif is last
    # wireguard = {
    #   enable = true;
    #   address = "10.34.0.2/24";
    #   privateKeyFile = config.age.secrets.wireguard-desktop-private-key.path;
    # };
  };

  age.secrets = myLib.mkWireguardSecrets [
    "wireguard-desktop-private-key"
  ];

  # DO NOT change! Used for backward compatibility.
  system.stateVersion = "25.05";
}
