# Based on https://wiki.nixos.org/wiki/WireGuard#systemd.network
{ config, lib, ... }:
let
  cfg = config.myModules.system.wireguard;
  listenPort = 51820;
  kubernetes = config.myModules.system.kubernetes.enable;
  # * On Kubernetes, route only specific traffic to avoid loops.
  # * Outside Kubernetes, route all traffic through the VPN.
  allowedIPs =
    lib.optionals kubernetes [
      "10.34.0.0/24" # VPN
      "10.43.0.0/16" # K8s cluster
    ]
    ++ lib.optionals (!kubernetes) [
      "0.0.0.0/0" # all traffic
    ];
in
{
  options.myModules.system.wireguard = {
    enable = lib.mkEnableOption "Enable Wireguard client";
    address = lib.mkOption { type = lib.types.str; };
    privateKeyFile = lib.mkOption { type = lib.types.str; };
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
              allowedIPs = allowedIPs;
              endpoint = "ruggeri.asuscomm.com:51820";
              persistentKeepalive = 15;
            }
          ];
        };
      };
    };
  };
}
