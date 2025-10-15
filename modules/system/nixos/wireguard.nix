# Based on https://wiki.nixos.org/wiki/WireGuard#systemd.network
{ config, lib, ... }:
let
  cfg = config.myModules.system.wireguard;
  listenPort = 51820;
in
{
  options.myModules.system.wireguard = {
    enable = lib.mkEnableOption "Enable Wireguard client";
    address = lib.mkOption { type = lib.types.str; };
    privateKeyFile = lib.mkOption { type = lib.types.str; };
    presharedKeyFile = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      firewall.allowedUDPPorts = [ listenPort ];
      wg-quick.interfaces = {
        wg0 = {
          address = [ cfg.address ];
          dns = [ "10.43.0.12" ];
          privateKeyFile = cfg.privateKeyFile;
          peers = [
            {
              publicKey = "PqMzcV9O8M/X6EkM9OETa065Vg1mTHWaikbQR5Z55Ro=";
              presharedKeyFile = cfg.presharedKeyFile;
              allowedIPs = [
                "10.34.0.0/24" # VPN
                "10.43.0.0/16" # Kubernetes cluster
                "192.168.1.30/32" # Kubernetes API server
              ];
              endpoint = "ruggeri.asuscomm.com:51820";
              persistentKeepalive = 15;
            }
          ];
        };
      };
    };
  };
}
