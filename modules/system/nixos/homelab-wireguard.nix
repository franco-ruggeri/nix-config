# Based on https://wiki.nixos.org/wiki/WireGuard#wg-quick
{ config, lib, ... }:
let
  cfg = config.myModules.system.homelab.wireguard;
  listenPort = 51820;
  k8sCfg = config.myModules.system.homelab.k8s.master;
  k8sProduction = k8sCfg.enable && k8sCfg.production;
  allowedIPs =
    # On production K8s nodes, the production K8s cluster is accessible directly.
    # Only traffic to the WireGuard peers should go to the VPN.
    # Otherwise, there would be a network loop (client --> Wireguard --> repeat).
    lib.optionals k8sProduction [
      "10.34.0.0/24" # VPN
    ]
    # On other nodes, allow all traffic through the VPN.
    # This allows accessing the K8s cluster (cluster IPs and API server) via the VPN.
    ++ lib.optionals (!k8sProduction) [
      "0.0.0.0/0" # all traffic
    ];
in
{
  options.myModules.system.homelab.wireguard = {
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
    # DNS, which is required to resolve the endpoint, might not be available at that point.
    # As a simple workaround, we configure the service to restart on failure.
    # See https://discourse.nixos.org/t/why-do-i-have-to-restart-wireguard-on-every-reboot/46376/4
    systemd.services.wg-quick-wg0 = {
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "10s";
      };
      unitConfig = {
        StartLimitIntervalSec = 0;
      };
    };
  };
}
