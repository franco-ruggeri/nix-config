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
          "whatsapp-for-mac"
          "zoom"
          "vscode-extension-ms-vscode-cpptools"
          "steam"
          "steam-unwrapped"
        ];
      pkgsStable = import inputs.nixpkgs {
        inherit system;
        config.allowUnfreePredicate = allowUnfreePredicate;
      };
      pkgsUnstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfreePredicate = allowUnfreePredicate;
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
        config.allowUnfreePredicate = allowUnfreePredicate;
        overlays = [
          (self: super: {
            agenix = inputs.agenix.packages.${system}.default;
            steam-unwrapped = config.packages.steam-unwrapped;
            super-productivity = pkgsUnstable.super-productivity;
            # Warning: The stable Nix package is currently broken.
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
