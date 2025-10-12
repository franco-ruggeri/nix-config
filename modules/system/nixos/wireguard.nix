# Based on https://wiki.nixos.org/wiki/WireGuard#systemd.network
{
  config,
  lib,
  ...
}:
let
  cfg = config.myModules.system.wireguard;
in
{
  config = lib.mkIf cfg.enable {
    networking.firewall.allowedUDPPorts = [ cfg.listenPort ];

    systemd.network = {
      enable = true;

      networks.${cfg.device} = {
        matchConfig.Name = cfg.device;
        address = [ cfg.address ];
        networkConfig = {
          DNS = [ cfg.dns ];
          DNSDefaultRoute = true;
        };
      };

      netdevs.${cfg.device} = {
        netdevConfig = {
          Kind = "wireguard";
          Name = cfg.device;
        };

        wireguardConfig = {
          PrivateKeyFile = cfg.privateKeyFile;
          ListenPort = cfg.listenPort;
          RouteTable = "main";
        };

        wireguardPeers = [
          {
            PublicKey = cfg.serverPublicKey;
            PresharedKeyFile = cfg.presharedKeyFile;
            AllowedIPs = cfg.allowedIPs;
            Endpoint = cfg.endpoint;
          }
        ];
      };
    };
  };
}
