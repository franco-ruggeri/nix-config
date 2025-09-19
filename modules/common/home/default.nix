{ pkgs, ... }:

{
      home = {
    packages = with pkgs; [
        git
        tmux
        stow
        bitwarden-desktop
        python3
        nodejs
        cargo
        gcc
        unzip
        tree-sitter
        fzf
        fd
        ripgrep
        gnumake
        devpod
        oh-my-posh
        telegram-desktop
        aichat
      ];
  };

    programs = {
      # ghostty.enable = true;  # TODO: currently broken in nixpkgs?
      firefox.enable = true;
      thunderbird = {
        enable = true;
        profiles.default = { isDefault = true; };
      };
    gpg.enable = true;
    };

  services = {
    gpg-agent.enable = true;
  };


    # DO NOT change! Used for backward compatibility.
    home.stateVersion = "25.05";
}
