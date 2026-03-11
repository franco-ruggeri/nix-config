{ config, myLib, ... }:
{
  networking.hostName = "franco-ruggeri-desktop";

  myModules.system = {
    username = "franco";
    hashedPasswordFile = config.age.secrets.user-password-desktop.path;
    tui.enable = true;
    gui.enable = true;
    gaming.enable = true;
    zfs.enable = true;
    homelab = {
      nfs.server = {
        enable = true;
        # Read-write access from K8s nodes and K8s cluster
        rwIPs = [
          "10.34.0.2/32"
          "10.42.0.0/24"
        ];
        # Read-only access from backup servers
        roIPs = [
          "10.34.0.3/32"
          "10.34.0.5/32"
          "10.34.0.6/32"
        ];
      };
      k8s.master = {
        enable = true;
        tokenFile = config.age.secrets.k3s-token-production.path;
        clusterCidr = "10.42.0.0/16";
        serviceCidr = "10.43.0.0/16";
      };
      wireguard = {
        enable = true;
        address = "10.34.0.2/24";
        privateKeyFile = config.age.secrets.wireguard-private-key-desktop.path;
      };
    };
  };

  age.secrets =
    myLib.mkSecrets [
      "user-password-desktop"
      "k3s-token-production"
    ]
    // myLib.mkWireguardSecrets [ "wireguard-private-key-desktop" ];

  # DO NOT change! Used for backward compatibility.
  system.stateVersion = "25.05";
}
