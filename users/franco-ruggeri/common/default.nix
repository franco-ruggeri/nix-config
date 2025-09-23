{ pkgs, myLib, ... }:

{
  home.packages = with pkgs; [
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
    zoom-us
    super-productivity

    # TODO: for some reason, nil_ls fails to compile on macos with mason... 
    # I need to find a consistent way, either drop Mason for everything or make nil work with mason
    nil
  ];

  programs = {
    zsh.enable = true;
    neovim.enable = true;
    gpg.enable = true;
    firefox.enable = true;
    obs-studio.enable = true;
    mpv.enable = true;
  };

  services.gpg-agent.enable = true;

  xdg.configFile = myLib.mkConfigFiles ./config;
}
