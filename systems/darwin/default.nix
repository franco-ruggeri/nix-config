{ pkgs, ... }:

{ 
  homebrew = {
  enable = true;
    brews = [];
    casks = [ 
      # Warning: The Nix option (services.karabiner-elements) is currently broken.
      # See https://github.com/nix-darwin/nix-darwin/issues/1041
      # TODO: add reminder with waiting-for
      "karabiner-elements"
      # Warning: The Nix option (programs.ghostty) is currently broken.
      # See https://github.com/NixOS/nixpkgs/issues/388984
      # TODO: add reminder with waiting-for
      "ghostty"
    ];
  };
}
