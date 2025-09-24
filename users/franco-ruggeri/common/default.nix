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
      history.ignoreSpace = true;
    };
    oh-my-posh = {
      enable = true;
      enableZshIntegration = true;
      settings = myLib.readJSON config/oh-my-posh/config.json;
    };
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    gpg.enable = true;
    fzf = {
      enable = true;
      enableZshIntegration = true;
      # Consistent layout for fzf, <C-t>, <C-r>, and <M-c>
      defaultOptions = [ "--tmux=center" "--layout=reverse" ];
    };
    firefox.enable = true;
    mpv.enable = true;
  };

  xdg.configFile = myLib.mkConfigFiles ./config;
}
