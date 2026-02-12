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
    ./wireguard.nix
    ./kubernetes.nix
    ./nfs-server.nix
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

  nix.gc.dates = "weekly";

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
    amdgpu.opencl.enable = true;
    openrazer = {
      enable = true;
      users = [ config.myModules.system.username ];
    };
  };

  age.secrets = myLib.mkSecrets [ "user-password" ];
}
