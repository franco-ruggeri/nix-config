# Based on https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/cluster/k3s/docs/USAGE.md
{
  config,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.system.homelab.kubernetes;
  adminGroup = "kubeadmin";
in
{
  options.myModules.system.homelab.kubernetes = {
    enable = lib.mkEnableOption "Enable Kubernetes for homelab";
    server = lib.mkOption { type = lib.types.str; };
    tokenFile = lib.mkOption { type = lib.types.str; };
    clusterCidr = lib.mkOption { type = lib.types.str; };
    serviceCidr = lib.mkOption { type = lib.types.str; };
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
        tokenFile = cfg.tokenFile;
        extraFlags = [
          "--cluster-cidr=${cfg.clusterCidr}"
          "--service-cidr=${cfg.serviceCidr}"
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

    users = {
      groups.${adminGroup} = { };
      users.${config.myModules.system.username}.extraGroups = [ adminGroup ];
    };

    systemd = {
      services = {
        # Path to make Longhorn find openiscsi
        # See https://github.com/longhorn/longhorn/issues/2166
        iscsid.serviceConfig = {
          PrivateMounts = "yes";
          BindPaths = "/run/current-system/sw/bin:/bin";
        };
        homelab-backup-k8s =
          let
            pythonScriptDir = myLib.mkPythonScriptDir {
              derivationName = "homelab_backup_k8s";
              scriptNames = [
                "homelab_backup_k8s.py"
                "homelab_backup_utils.py"
              ];
            };
          in
          {
            description = "Homelab backup K8s";
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${pythonScriptDir}/homelab_backup_k8s.py";
              WorkingDirectory = pythonScriptDir;
              Environment = [
                "PATH=/run/current-system/sw/bin/:/usr/bin:/bin:/usr/sbin:/sbin"
                "SMTP_PASSWORD_FILE=${config.age.secrets.smtp-password.path}"
              ];
            };
          };
      };
      timers.homelab-backup-k8s = {
        description = "Homelab backup K8s";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "01:00";
          Persistent = true;
        };
      };
    };
  };
}
