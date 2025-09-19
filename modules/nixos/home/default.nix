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
        whatsie
        telegram-desktop
        pamixer
        hyprpaper
        wofi
        dunst
        slurp
        grim
        wl-clipboard
        adwaita-icon-theme
        nemo
        aichat
        hyprpolkitagent
      ];
      pointerCursor = {
        gtk.enable = true;
        # x11.enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 16;
      };
  };

    programs = {
      ghostty.enable = true;
      firefox.enable = true;
      thunderbird = {
        enable = true;
        profiles.default = { isDefault = true; };
      };
    };

    wayland.windowManager.hyprland.enable = true;

    xdg.configFile."hypr/hyprland.conf".source =
      /home/franco-ruggeri/dotfiles/.config/hypr/hyprland.conf;

    gtk = {
      enable = true;

      theme = {
        package = pkgs.flat-remix-gtk;
        name = "Flat-Remix-GTK-Grey-Darkest";
      };

      iconTheme = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
      };

      font = {
        name = "Sans";
        size = 11;
      };
    };

    # DO NOT change! Used for backward compatibility.
    home.stateVersion = "25.05";
}
