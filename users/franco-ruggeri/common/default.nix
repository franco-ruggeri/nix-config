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
    fd
    ripgrep
    gnumake
    devpod
    oh-my-posh
    telegram-desktop
    spotify
    discord
    super-productivity
    zoom-us

    # TODO: for some reason, nil_ls fails to compile on macos with mason... 
    # I need to find a consistent way, either drop Mason for everything or make nil work with mason
    nil
  ];

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      envExtra = "source $HOME/.config/zsh/zshenv.sh";
      initContent = "source $HOME/.config/zsh/zshrc.sh";
    };
    oh-my-posh = {
      enable = true;
      enableZshIntegration = true;
      settings = builtins.fromJSON (builtins.unsafeDiscardStringContext
        (builtins.readFile config/oh-my-posh/config.json));
    };
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    gpg.enable = true;
    firefox.enable = true;
    obs-studio.enable = true;
    mpv.enable = true;
  };

  services.gpg-agent.enable = true;

  xdg.configFile = myLib.mkConfigFiles ./config;
}
