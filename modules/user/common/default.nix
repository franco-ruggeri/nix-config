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

    # TODO: for some reason, nil_ls fails to compile on macos with mason... 
    # I need to find a consistent way, either drop Mason for everything or make nil work with mason
    nil
  ];

  programs.firefox.enable = true;

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [ "spotify" "discord" ];

  # TODO: doesn't work on darwin... maybe it shoudl be moved to linux
  #environment.systemPackages = (with pkgs; [ vim discord spotify ]);
  # TODO: need to find a good way to pass nixos-unstable here... doesn't work with flake
  # ++ (let unstable = import <nixos-unstable> { };
  # in with unstable; [ super-productivity ]);
}
