# Based on https://wiki.nixos.org/wiki/WireGuard#systemd.network
{
  config,
  lib,
  ...
}:
let
  cfg = config.myModules.system.wireguard;
  deviceName = "wg0";
  configFile = "50-wg0";
in
{
  options.myModules.system.wireguard = {
    enable = lib.mkEnableOption "Enable Kubernetes";
    privateKeyFile = lib.mkOption { type = lib.types.str; };
    presharedKeyFile = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      firewall.allowedUDPPorts = [ 51820 ];
      useNetworkd = true;
    };

    systemd.network = {
      enable = true;

      networks.${configFile} = {
        matchConfig.Name = deviceName;
        address = [ "10.34.0.2/32" ];
        networkConfig = {
          DNS = [ "10.34.0.240" ];
          DNSDefaultRoute = true;
        };
      };

      netdevs.${configFile} = {
        netdevConfig = {
          Kind = "wireguard";
          Name = deviceName;
        };

        wireguardConfig = {
          PrivateKeyFile = cfg.privateKeyFile;
          ListenPort = 51820;
          RouteTable = "main";
        };

        wireguardPeers = [
          {
            PublicKey = "t7KA7wnR5f3+kasDl0e8qMRmtS2hQaBDy9IwoEKnTXs="; # TODO: this should be somehow fixed. Now it changes at every restart of the cluster
            PresharedKeyFile = cfg.presharedKeyFile;
            AllowedIPs = [ "10.34.0.0/24" ];
            Endpoint = "ruggeri.asuscomm.com:51820";
          }
        ];
      };
    };
  };
}
