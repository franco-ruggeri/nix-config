# Based on https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/cluster/k3s/docs/USAGE.md
{
  config,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.system.homelab.k8s;
  group = "homelab-admin";
in
{
  options.myModules.system.homelab.k8s = {
    enable = lib.mkEnableOption "Enable Kubernetes master for homelab";
    tokenFile = lib.mkOption { type = lib.types.str; };
    production = lib.mkOption { type = lib.types.bool; };
  };

  config = lib.mkIf cfg.enable {
    environment.etc = myLib.mkEtcFiles [
      "rancher/k3s/config.yaml"
      "rancher/k3s/psa.yaml"
      "sysctl.d/99-k3s.conf"
    ];

    networking = {
      firewall = {
        allowedTCPPorts = [
          6443 # k3s API server
          10250 # kubelet metrics
          9100 # prometheus node exporter
        ];
        allowedUDPPorts = [
          8472 # k3s flannel
          51820 # wireguard
        ];
      };
    };

    services = {
      k3s = {
        enable = true;
        role = "server";
        clusterInit = true;
        tokenFile = cfg.tokenFile;
        # Change CIDRs for non-production clusters so that non-production k8s
        # nodes can still use the production services (VPN, DNS, services).
        extraFlags = lib.mkIf (!cfg.production) [
          "--cluster-cidr=10.45.0.0/16"
          "--service-cidr=10.46.0.0/16"
        ];
      };
      openiscsi = {
        enable = true; # for longhorn
        name = "iqn.2025-11.local.nixos:${config.networking.hostName}";
      };
    };

    users = {
      groups.${group} = { };
      users.${config.myModules.system.username}.extraGroups = [ group ];
    };

    systemd.services.iscsid.serviceConfig = {
      # Path to make Longhorn find openiscsi
      # See https://github.com/longhorn/longhorn/issues/2166
      PrivateMounts = "yes";
      BindPaths = "/run/current-system/sw/bin:/bin";
    };

  };
}
