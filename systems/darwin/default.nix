{ home-manager, ... }:
{
  imports = [
    home-manager.darwinModules.home-manager
    ../common
    ../../modules/system/darwin
  ];

  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    brews = [ ];
    casks = [
      "google-drive"
      # WARNING: The Nix option (services.karabiner-elements) is currently broken.
      # See https://github.com/nix-darwin/nix-darwin/issues/1041
      "karabiner-elements"
      # WARNING: The Nix option (programs.ghostty) is currently broken.
      # See https://github.com/NixOS/nixpkgs/issues/388984
      "ghostty"
      # WARNING: The Nix package (pkgs.obs-studio) does not support darwin currently.
      # See https://github.com/NixOS/nixpkgs/issues/411190
      "obs"
    ];
    masApps = {
      "WireGuard" = 1451685025;
    };
  };
}
