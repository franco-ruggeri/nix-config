{ pkgs, home-manager, ... }:

{
  imports = [ ./kubernetes.nix ];

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

  nix = {
    settings.experimental-features = "nix-command flakes";
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  programs = {
    hyprland.enable = true;
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
}
