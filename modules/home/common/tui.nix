{
  config,
  pkgs,
  lib,
  myLib,
  ...
}:
let
  cfg = config.myModules.home.tui;
in
{
  options.myModules.home.tui.enable = lib.mkEnableOption "Enables TUI home configuration.";

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        aichat
        opencode
        tmux
        python3
        uv
        nodejs
        cargo
        gcc
        unzip
        tree-sitter
        fd
        ripgrep
        gnumake
        oh-my-posh
        cmake
        kubectl
        kubernetes-helm
        fluxcd
        k3d
        tree
        dig
        git
        devpod
        sops
        age
        texliveFull
      ];
    };

    programs = {
      zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        shellAliases = {
          aichat = "GEMINI_API_KEY=$(cat ${config.age.secrets.gemini-api-key.path}) aichat";
        };
        envExtra = "source $HOME/.config/zsh/zshenv.sh";
        initContent = "source $HOME/.config/zsh/zshrc.sh";
        history.ignoreSpace = true;
      };
      oh-my-posh = {
        enable = true;
        enableZshIntegration = true;
        settings = myLib.fromJSON (builtins.readFile (myLib.dotfilesConfigDir + "/oh-my-posh/config.json"));
      };
      htop.enable = true;
      fzf = {
        enable = true;
        enableZshIntegration = true;
        # Consistent layout (<C-t>, <C-r>, and <M-c>)
        defaultOptions = [
          "--tmux=center"
          "--layout=reverse"
        ];
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
          vscode-extensions.ms-vscode.cpptools

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
    };

    xdg.configFile =
      let
        nvim_constants = {
          "nvim/lua/utils/constants.lua".text = ''
            return {
              VSCODE_CPPTOOLS = "${pkgs.vscode-extensions.ms-vscode.cpptools}",
              VSCODE_JAVA_DEBUG = "${pkgs.vscode-extensions.vscjava.vscode-java-debug}",
              VSCODE_JAVA_TEST = "${pkgs.vscode-extensions.vscjava.vscode-java-test}",
            }
          '';
        };
      in
      myLib.mkConfigDotfiles [
        "aichat"
        "marksman"
        "mcphub"
        "nvim"
        "tmux"
        "zsh"
        "git"
      ]
      // nvim_constants;

    age.secrets = myLib.mkSecrets [ "gemini-api-key" ];
  };
}
