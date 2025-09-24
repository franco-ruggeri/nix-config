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
        # Lua
        # lua-language-server # language server
        # stylua # formatter

        # Bash
        # bash-language-server # language server
        # shfmt # formatter

        # Markdown
        # marksman # language server
        # markdownlint # linter
        # prettier # formatter

        # JSON
        # json-lsp # language server with linter
        # prettier # formatter

        # YAML
        # yaml-language-server # language server
        # prettier # formatter

        # TOML
        # taplo # language server with formatter

        # XML
        # lemminx # language server with formatter

        # Helm
        # helm-ls # language server

        # Docker
        # dockerfile-language-server # language server
        # hadolint # linter

        # Python
        # python-lsp-server # language server
        # ruff # linter and formatter
        # pylint # linter (some rules not covered by ruff, see https://github.com/astral-sh/ruff/issues/970)
        # mypy # linter (static type checker)

        # C/C++
        # clangd # language server
        # clang-format # formatter
        # cpptools # debug adapter

        # TypeScript and JavaScript
        # typescript-language-server # language server
        # prettier # formatter

        # LaTeX
        # texlab # language server with formatter

        # Java
        # jdtls # language server
        # google-java-format # formatter
        # java-debug-adapter # debug adapter
        # java-test # use debug adapter on tests

        # Nix
        nil # language server with linter
        nixfmt-rfc-style # formatter
      ];
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
