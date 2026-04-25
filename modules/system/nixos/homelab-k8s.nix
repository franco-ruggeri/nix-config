# Based on https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/cluster/k3s/docs/USAGE.md
{
  config,
  pkgs,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.system.homelab.k8s;
  adminGroup = "kubeadmin";
in
{
  options.myModules.system.homelab.k8s = {
    enable = lib.mkEnableOption "Enable Kubernetes master for homelab";
    tokenFile = lib.mkOption { type = lib.types.str; };
    production = lib.mkOption { type = lib.types.bool; };
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
        clusterInit = true;
        tokenFile = cfg.tokenFile;
        extraFlags =
          # Change CIDRs for non-production clusters so that non-production k8s
          # nodes can still use the production services (VPN, DNS, services).
          lib.optionals (!cfg.production) [
            "--cluster-cidr=10.45.0.0/16"
            "--service-cidr=10.46.0.0/16"
          ]
          ++ [
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

    systemd = lib.mkMerge [
      {
        # Path to make Longhorn find openiscsi
        # See https://github.com/longhorn/longhorn/issues/2166
        services.iscsid.serviceConfig = {
          PrivateMounts = "yes";
          BindPaths = "/run/current-system/sw/bin:/bin";
        };
      }
      (lib.mkIf cfg.production {
        services.homelab-backup-k8s =
          let
            homelabBackupPython = myLib.mkPythonPackage {
              derivationName = "homelab-backup-python";
              packageName = "homelab_backup";
            };
          in
          {
            description = "Homelab backup K8s";
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${pkgs.python3}/bin/python -m homelab_backup k8s";
              WorkingDirectory = homelabBackupPython;
              Environment = [
                "PATH=/run/current-system/sw/bin/:/usr/bin:/bin:/usr/sbin:/sbin"
                "PYTHONPATH=${homelabBackupPython}"
                "SMTP_PASSWORD_FILE=${config.age.secrets.smtp-password.path}"
              ];
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
      })
    ];
  };
}
