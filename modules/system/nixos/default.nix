{
  config,
  pkgs,
  agenix,
  myLib,
  ...
}:
let
  cfg = config.myModules.system;
in
{
  imports = [
    agenix.nixosModules.default
    ../common
    ./gui
    ./tui
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

  age.secrets = myLib.mkSecrets [ "user-password" ];
}
