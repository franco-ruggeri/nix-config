{ pkgs, mylib, pkgsUnstable, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [ "spotify" "discord" ];

  home.packages = (with pkgs; [
    aichat
    git
    tmux
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
    spotify
    discord

    # TODO: for some reason, nil_ls fails to compile on macos with mason... 
    # I need to find a consistent way, either drop Mason for everything or make nil work with mason
    nil
  ]) ++ (with pkgsUnstable; [ super-productivity ]);

  programs = {
    zsh.enable = true;
    neovim.enable = true;
    gpg.enable = true;
    firefox.enable = true;
  };

  services.gpg-agent.enable = true;

  xdg.configFile = mylib.mkConfigFiles ./config;
}
