{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myModules.system;
in
{
  imports = [
    ../common
    ./gui.nix
    ./tui.nix
    ./gaming.nix
    ./zfs.nix
    ./homelab-k8s.nix
    ./homelab-wireguard.nix
    ./homelab-nfs.nix
    ./homelab-backup-source.nix
    ./homelab-backup-dest.nix
  ];

  options.myModules.system = {
    hashedPasswordFile = lib.mkOption { type = lib.types.str; };
  };

  config = {
    networking = {
      networkmanager.enable = true;
      useDHCP = lib.mkDefault true;
    };

    time.timeZone = "Europe/Stockholm";

    system.autoUpgrade = {
      enable = true;
      dates = "weekly";
    };

    users = {
      mutableUsers = false;
      users.${cfg.username} = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        shell = pkgs.zsh;
        hashedPasswordFile = cfg.hashedPasswordFile;
      };
    };

    hardware = {
      cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      openrazer = {
        enable = true;
        users = [ config.myModules.system.username ];
      };
    };

    systemd.watchdog = {
      device = "/dev/watchdog";
      kexecTime = "5min";
      rebootTime = "10min";
      runtimeTime = "30s";
    };
  };
}
