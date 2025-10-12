{ lib, ... }:
{
  options.myModules.system.wireguard = {
    enable = lib.mkEnableOption "Enable Wireguard client";
    address = lib.mkOption { type = lib.types.str; };
    privateKeyFile = lib.mkOption { type = lib.types.str; };
    presharedKeyFile = lib.mkOption { type = lib.types.str; };
    serverPublicKey = lib.mkOption {
      type = lib.types.str;
      default = "PqMzcV9O8M/X6EkM9OETa065Vg1mTHWaikbQR5Z55Ro=";
    };
    endpoint = lib.mkOption {
      type = lib.types.str;
      default = "ruggeri.asuscomm.com:51820";
    };
    dns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "10.43.0.12"
        "8.8.8.8"
      ];
    };
    allowedIPs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "10.34.0.0/24" # VPN
        "10.43.0.0/16" # Kubernetes cluster
      ];
    };
    listenPort = lib.mkOption {
      type = lib.types.int;
      default = 51820;
    };
    device = lib.mkOption {
      type = lib.types.str;
      default = "wg0";
    };
  };
}
