# Based on https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/cluster/k3s/docs/USAGE.md
{ config, lib, ... }:
let
  cfg = config.myModules.system.kubernetes;
in
{
  options.myModules.system.kubernetes = {
    enable = lib.mkEnableOption "Enable Kubernetes";
    server = lib.mkOption { type = lib.types.str; };
    token = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      firewall = {
        allowedTCPPorts = [
          6443
          2379
          2380
        ];
        allowedUDPPorts = [
          8472
        ];
      };
    };

    services = {
      k3s = {
        enable = true;
        role = "server";
        # TODO: for multi-node, I need the below. For that, I need to manage the token securely... with agenix
        # clusterInit = cfg.server == config.networking.hostName;
        # serverAddr = lib.mkIf config.services.k3s.clusterInit "https://${cfg.server}:6443";
        # token = cfg.token;
      };
    };
  };
}
