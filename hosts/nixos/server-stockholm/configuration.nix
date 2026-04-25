{ config, myLib, ... }:
{
  networking.hostName = "franco-ruggeri-server-stockholm";

  myModules.system = {
    username = "franco";
    hashedPasswordFile = config.age.secrets.user-password-server-stockholm.path;
    tui.enable = true;
    zfs.enable = true;

    homelab = {
      # Production
      wireguard = {
        enable = true;
        address = "10.34.0.6/24";
        privateKeyFile = config.age.secrets.wireguard-private-key-server-stockholm.path;
      };
      backup.dst = {
        enable = true;
        sourceHost = "10.34.0.2";
        sourceUser = "franco";
      };

      # Staging
      nfs = {
        enable = true;
        rwIPs = [ "10.34.0.6/32" ];
        roIPs = [ ];
        production = false;
      };
      k8s = {
        enable = true;
        tokenFile = config.age.secrets.k3s-token-staging.path;
        production = false;
      };
    };
  };

  age.secrets =
    myLib.mkSecrets [
      "user-password-server-stockholm"
      "k3s-token-staging"
    ]
    // myLib.mkWireguardSecrets [ "wireguard-private-key-server-stockholm" ];

  # DO NOT change! Used for backward compatibility.
  system.stateVersion = "25.05";
}
