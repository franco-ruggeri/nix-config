# Based on https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/cluster/k3s/docs/USAGE.md
{
  config,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.system.kubernetes;
  adminGroup = "kubeadmin";
in
{
  options.myModules.system.kubernetes = {
    enable = lib.mkEnableOption "Enable Kubernetes";
    server = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
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
        clusterInit = cfg.server == config.networking.hostName;
        serverAddr = lib.mkIf (!config.services.k3s.clusterInit) "https://${cfg.server}:6443";
        token = config.age.secrets.k3s-token.path;
        extraFlags = [
          "--write-kubeconfig-mode=640"
          "--write-kubeconfig-group=${adminGroup}"
          "--disable=traefik"
          "--disable=servicelb"
          "--disable=local-storage"
        ];
      };
      openiscsi = {
        enable = true; # for longhorn
        name = "iqn.2025-11.local.nixos:${config.networking.hostName}";
      };
    };

    # Path to make Longhorn find openiscsi
    # See https://github.com/longhorn/longhorn/issues/2166
    systemd.services.iscsid.serviceConfig = {
      PrivateMounts = "yes";
      BindPaths = "/run/current-system/sw/bin:/bin";
    };

    users = {
      groups.${adminGroup} = { };
      users.${config.myModules.system.username}.extraGroups = [ adminGroup ];
    };

    age.secrets = myLib.mkSecrets [ "k3s-token" ];
  };
}
