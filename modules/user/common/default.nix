{ pkgs, ... }:

{
  imports = [ ./neovim ./zsh ./git ./ghostty ./tmux ./aichat ];

  home.packages = with pkgs; [
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
  ];

  programs.firefox.enable = true;
}
