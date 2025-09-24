{ inputs, ... }:
{
  systems = [
    "x86_64-linux"
    "aarch64-darwin"
  ];
  perSystem =
    { system, pkgs, ... }:
    let
      allowUnfreePredicate =
        pkg:
        builtins.elem (pkgs.lib.getName pkg) [
          "spotify"
          "discord"
          "super-productivity"
          "whatsapp-for-mac"
          "zoom"
          "vscode-extension-ms-vscode-cpptools"
        ];
      pkgsUnstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfreePredicate = allowUnfreePredicate;
      };
    in
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfreePredicate = allowUnfreePredicate;
        overlays = [
          (self: super: {
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
