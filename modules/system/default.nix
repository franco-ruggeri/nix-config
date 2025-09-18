{ pkgs, ... }:

{
  imports = [ ./kubernetes.nix ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    # TODO: this should be machine-specific
    hostName = "franco-ruggeri-dl";
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Stockholm";

  users = {
    # TODO: first I need to manage the passwords with agenix
    # mutableUsers = false;
    users = {
      franco-ruggeri = {
        isNormalUser = true;
        description = "Franco Ruggeri";
        extraGroups = [ "networkmanager" "wheel" "docker" ];
        shell = pkgs.zsh;
        packages = [ ]; # TODO: move some packages here
      };
    };
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [ "spotify" "discord" ];

  # TODO: some of these packages should be probably moved to the user pkgs
  environment.systemPackages = (with pkgs; [ neovim discord spotify ])
    ++ (let unstable = import <nixos-unstable> { };
    in with unstable; [ super-productivity ]);

  # TODO: some of the programs can be per-user (home manager instead of here)
  programs = {
    zsh.enable = true;
    hyprland.enable = true;
    hyprlock.enable = true;
    waybar.enable = true;
    gnupg.agent = {
      enable = true;
      # TODO: In the next version (>25.05):
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
    seahorse.enable = true;
  };

  services = {
    openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
    };
    gnome.gnome-keyring.enable = true;
    hardware.openrgb.enable = true;
    playerctld.enable = true;
    hypridle.enable = true;
  };

  fonts.packages = with pkgs;
    builtins.filter lib.attrsets.isDerivation
    (builtins.attrValues pkgs.nerd-fonts); # all nerd fonts

  virtualisation.docker.enable = true;

  system = {
    autoUpgrade = {
      enable = true;
      dates = "weekly";
    };
    copySystemConfiguration = true;
    # DO NOT change! Necessary for mantaining compatibility on upgrades.
    # TODO: should it be machine specific?
    stateVersion = "25.05";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
