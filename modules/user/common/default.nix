{ pkgs, ... }:

{
  imports = [ ./aichat ./ghostty ./git ./neovim ./tmux ./zsh ];

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

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [ "spotify" "discord" ];

  environment.systemPackages = (with pkgs; [ vim discord spotify ]);
  # TODO: need to find a good way to pass nixos-unstable here... doesn't work with flake
  # ++ (let unstable = import <nixos-unstable> { };
  # in with unstable; [ super-productivity ]);
}
