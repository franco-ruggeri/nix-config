{ pkgs, home-manager, myLib, ... }:

{
  imports = [
    home-manager.nixosModules.home-manager
    ../common
    ../../modules/system/nixos
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Stockholm";

  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
  };

  nix.gc.dates = "weekly";

  programs = {
    hyprland.enable = true;
    seahorse.enable = true;
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
    hardware.openrgb.enable = true;
  };

  virtualisation.docker.enable = true;
}
