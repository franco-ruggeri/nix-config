# Based on https://wiki.nixos.org/wiki/WireGuard#systemd.network
{ config, lib, ... }:
let
  cfg = config.myModules.system.wireguard;
  listenPort = 51820;
  device = "wg0";
in
{
  options.myModules.system.wireguard = {
    enable = lib.mkEnableOption "Enable Wireguard client";
    address = lib.mkOption { type = lib.types.str; };
    privateKeyFile = lib.mkOption { type = lib.types.str; };
    presharedKeyFile = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedUDPPorts = [ listenPort ];

    systemd.network = {
      enable = true;

      networks.${device} = {
        matchConfig.Name = device;
        address = [ cfg.address ];
        networkConfig = {
          DNS = [
            "10.43.0.12"
            "8.8.8.8"
          ];
          DNSDefaultRoute = true;
        };
      };

      netdevs.${device} = {
        netdevConfig = {
          Kind = "wireguard";
          Name = device;
        };

        wireguardConfig = {
          PrivateKeyFile = cfg.privateKeyFile;
          ListenPort = listenPort;
          RouteTable = "main";
        };

        wireguardPeers = [
          {
            PublicKey = "PqMzcV9O8M/X6EkM9OETa065Vg1mTHWaikbQR5Z55Ro=";
            PresharedKeyFile = cfg.presharedKeyFile;
            AllowedIPs = [
              "10.34.0.0/24" # VPN
              "10.43.0.0/16" # Kubernetes cluster
            ];
            Endpoint = "ruggeri.asuscomm.com:51820";
          }
        ];
      };
    };
  };
}
