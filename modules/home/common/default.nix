{
  config,
  pkgs,
  lib,
  myLib,
  agenix,
  ...
}:
{
  imports = [ agenix.homeManagerModules.default ];

  options.myModules.home.username = lib.mkOption {
    type = lib.types.str;
    description = "The username of the main user.";
  };

  config = {
    home = {
      packages = with pkgs; [
        agenix.packages.${pkgs.system}.default
        aichat
        zotero
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
        inkscape
        slack
      ];
    };

    programs = {
      home-manager.enable = true;
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
        settings = myLib.readJSON config/oh-my-posh/config.json;
      };
      gpg.enable = true;
      fzf = {
        enable = true;
        enableZshIntegration = true;
        # Consistent layout (<C-t>, <C-r>, and <M-c>)
        defaultOptions = [
          "--tmux=center"
          "--layout=reverse"
        ];
      };
      firefox.enable = true;
      mpv.enable = true;
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

    xdg.configFile = myLib.mkConfigDir ./config // {
      "nvim/lua/utils/constants.lua".text = ''
        return {
          VSCODE_CPPTOOLS = "${pkgs.vscode-extensions.ms-vscode.cpptools}",
          VSCODE_JAVA_DEBUG = "${pkgs.vscode-extensions.vscjava.vscode-java-debug}",
          VSCODE_JAVA_TEST = "${pkgs.vscode-extensions.vscjava.vscode-java-test}",
        }
      '';
    };

    age = {
      identityPaths = [ "${config.home.homeDirectory}/.ssh/agenix" ];
      secrets = myLib.mkSecrets [ "gemini-api-key" ];
    };
  };
}
