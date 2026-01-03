# Based on https://wiki.nixos.org/wiki/WireGuard#systemd.network
{ config, lib, ... }:
let
  cfg = config.myModules.system.wireguard;
  listenPort = 51820;
  kubernetes = config.myModules.system.kubernetes.enable;
  allowedIPs =
    # On K8s nodes, the K8s cluster is accessible directly, without VPN.
    # Only traffic to the WireGuard peers should go to the VPN.
    # Otherwise, there would be a network loop (client --> Wireguard --> repeat).
    lib.optionals kubernetes [
      "10.34.0.0/24" # VPN
    ]
    # On non-K8s nodes, allow all traffic through the VPN.
    # This allows accessing K8s cluster (cluster IPs and API server) via the VPN.
    ++ lib.optionals (!kubernetes) [
      "0.0.0.0/0" # all traffic
    ];
in
{
  options.myModules.system.wireguard = {
    enable = lib.mkEnableOption "Enable WireGuard client connected to homelab";
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
          mtu = 1280;
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

    # WireGuard is started only once after network-online.target.
    # Unfortunately, DNS might not be available at that point.
    # The correct target to guarantee DNS available would be nss-lookup.target.
    # There are multiple solutions to this problem (e.g., using systemd-networkd).
    #
    # To keep it simple, we restart the service unit on failure.
    # See https://discourse.nixos.org/t/why-do-i-have-to-restart-wireguard-on-every-reboot/46376/4
    systemd.services.wg-quick-wg0 = {
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "10s";
      };
      unitConfig.StartLimitIntervalSec = 0;
    };
  };
}
