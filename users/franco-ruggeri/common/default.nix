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
    cmake
    kubernetes-helm
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
      extraPackages = with pkgs; [
        # Data serialization formats
        vscode-langservers-extracted # jsonls
        yaml-language-server
        taplo
        lemminx
        nodePackages.prettier

        # Lua
        lua-language-server
        stylua

        # Bash
        bash-language-server
        shfmt

        # Markdown
        marksman
        markdownlint-cli

        # Javascript/Typescript
        typescript-language-server
        vscode-js-debug

        # Docker
        docker-language-server
        hadolint

        # Helm
        helm-ls

        # Python
        python3Packages.python-lsp-server
        python3Packages.debugpy
        ruff
        pylint
        mypy

        # C/C++
        clang-tools # clangd and clang-format
        cpptools

        # LaTeX
        texlab

        # Java
        jdt-language-server
        google-java-format
        vscode-extensions.vscjava.vscode-java-debug # java-debug-adapter
        vscode-extensions.vscjava.vscode-java-test # to use debug adapter on tests

        # Nix
        nil
        nixfmt-rfc-style
      ];
    };
    gpg.enable = true;
    fzf = {
      enable = true;
      enableZshIntegration = true;
      # Consistent layout for fzf, <C-t>, <C-r>, and <M-c>
      defaultOptions = [
        "--tmux=center"
        "--layout=reverse"
      ];
    };
    firefox.enable = true;
    mpv.enable = true;
  };

  xdg.configFile = myLib.mkConfigFiles ./config;
}
