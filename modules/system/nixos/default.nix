{
  config,
  pkgs,
  lib,
  myLib,
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
    ./homelab-kubernetes.nix
    ./homelab-wireguard.nix
    ./homelab-nfs-server.nix
    ./homelab-nfs-client.nix
    ./homelab-backup.nix
  ];

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
      hashedPasswordFile = config.age.secrets.user-password.path;
    };
  };

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    openrazer = {
      enable = true;
      users = [ config.myModules.system.username ];
    };
  };

  age.secrets = myLib.mkSecrets [ "user-password" ];
}
