{ inputs, ... }:
{
  systems = [
    "x86_64-linux"
    "aarch64-darwin"
  ];
  perSystem =
    {
      config,
      system,
      pkgs,
      ...
    }:
    let
      allowUnfreePredicate =
        pkg:
        builtins.elem (pkgs.lib.getName pkg) [
          "spotify"
          "slack"
          "discord"
          "obsidian"
          "vscode"
          "whatsapp-for-mac"
          "zoom"
          "vscode-extension-ms-vscode-cpptools"
          "steam"
          "steam-unwrapped"
        ];
      permittedInsecurePackages = [
        "electron-36.9.5" # for heroic
        "electron-37.10.3" # for super-productivity
      ];
      pkgsConfig = {
        allowUnfreePredicate = allowUnfreePredicate;
        permittedInsecurePackages = permittedInsecurePackages;
      };
      pkgsStable = import inputs.nixpkgs {
        inherit system;
        config = pkgsConfig;
      };
      pkgsUnstable = import inputs.nixpkgs-unstable {
        inherit system;
        config = pkgsConfig;
      };
    in
    {
      packages = {
        # WARNING: This override is a workaround for this issue:
        # https://github.com/ValveSoftware/steam-for-linux/issues/8983
        # When it gets fixed upstream, remove this override.
        steam-unwrapped = import ../pkgs/steam-unwrapped { inherit (pkgsStable) steam-unwrapped; };
      };
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = pkgsConfig;
        overlays = [
          (self: super: {
            agenix = inputs.agenix.packages.${system}.default;
            steam-unwrapped = config.packages.steam-unwrapped;
            fluxcd = pkgsUnstable.fluxcd;
            super-productivity = pkgsUnstable.super-productivity;
            spotify = pkgsUnstable.spotify;
            # WARNING: The stable Nix package currently has issues with providers.
            opencode = pkgsUnstable.opencode;
            # WARNING: The stable Nix package is currently broken.
            # See https://github.com/nixos/nixpkgs/issues/438745
            whatsapp-for-mac = pkgsUnstable.whatsapp-for-mac;
            # On darwin, the ghostty Nix package is broken.
            # See https://github.com/NixOS/nixpkgs/issues/388984
            # The brew version corresponds to unstable. So, we use unstable on linux for compatibility.
            ghostty = pkgsUnstable.ghostty;
          })
        ];
      };
    };
}
