{
  config,
  pkgs,
  agenix,
  myLib,
  ...
}:
{
  imports = [
    agenix.nixosModules.default
    ../common
    ./kubernetes.nix
    ./gaming.nix
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
    users.${config.myModules.system.username} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
      ];
      shell = pkgs.zsh;
      hashedPasswordFile = config.age.secrets.user-password.path;
    };
  };

  programs = {
    hyprland.enable = true;
    seahorse.enable = true;
    gnupg.agent = {
      enable = true;
      # TODO: In the next NixOS version (>25.05):
      #   - Use gcr-ssh-agent as an SSH agent and remove this.
      #   - Delete ~/.gnupg/private-keys-v1.d/ (SSH keys are stored there)
      #   Reason:
      #   Using the GPG agent as an SSH agent is a workaround to make gnome-keyring work with SSH.
      #   The better solution would be to use the bundled SSH agent in gnome-keyring.
      #   However, gnome-keyring no longer includes an SSH agent. It's been moved to gcr-ssh-agent (gcr package).
      #   The current version 25.05 does not provide an option for it. The unstable version has fixed it.
      #   See https://github.com/NixOS/nixpkgs/pull/379731
      enableSSHSupport = true;
    };
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
    # WARNING: The home-manager module (services.gnome-keyring) does not work.
    # See https://github.com/nix-community/home-manager/issues/1454
    gnome.gnome-keyring.enable = true;
  };

  virtualisation.docker.enable = true;

  age.secrets = myLib.mkSecrets ../../../secrets/system/nixos;
}
