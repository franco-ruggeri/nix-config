{ pkgs, myLib, ... }:

let gnomeTheme = "Adwaita-dark";
in {
  imports = [ ../common ../../../modules/user/linux ];

  home.packages = with pkgs; [ dunst pamixer slurp grim wl-clipboard whatsie ];

  programs = {
    ghostty.enable = true;
    hyprlock.enable = true;
    waybar.enable = true;
    wofi.enable = true;
  };

  services = {
    hyprpaper.enable = true;
    hyprpolkitagent.enable = true;
    hypridle.enable = true;
    playerctld.enable = true;
    gnome-keyring = {
      enable = true;
      components = [ "secrets" "ssh" ];
    };
    # gpg-agent.enable = true;
    # TODO: maybe I'll not need it anymore, trying enabling ssh in gnome-keyring, as HM has an option for the components (see above)
    # I need to try if it works or not. If it works, delete the gpg.agent section below.
    # gnupg.agent = {
    #   enable = true;
    #   # TODO: In the next version (>25.05):
    #   #   - Use gcr-ssh-agent as an SSH agent and remove this.
    #   #   - Delete ~/.gnupg/private-keys-v1.d/ (SSH keys are stored there)
    #   #   Reason:
    #   #   Using the GPG agent as an SSH agent is a workaround to make gnome-keyring work with SSH.
    #   #   The better solution would be to use the bundled SSH agent in gnome-keyring.
    #   #   However, gnome-keyring no longer includes an SSH agent. It's been moved to gcr-ssh-agent (gcr package).
    #   #   The current version 25.05 does not provide an option for it. The unstable version has fixed it.
    #   #   See https://github.com/NixOS/nixpkgs/pull/379731
    #   enableSSHSupport = true;
    # };
  };

  wayland.windowManager.hyprland.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  gtk = {
    enable = true;
    theme = {
      name = gnomeTheme;
      package = pkgs.gnome-themes-extra;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = gnomeTheme;
  };

  xdg.configFile = myLib.mkConfigFiles ./config;
}
