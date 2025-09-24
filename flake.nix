{
  description = "Franco Ruggeri's Nix config";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (topLevel@{ withSystem, ... }: {
      # Nixpkgs overlay
      # ====================
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      perSystem = { system, pkgs, ... }:
        let
          allowUnfreePredicate = pkg:
            builtins.elem (pkgs.lib.getName pkg) [
              "spotify"
              "discord"
              "super-productivity"
              "whatsapp-for-mac"
              "zoom"
            ];
          pkgsUnstable = import inputs.nixpkgs-unstable {
            inherit system;
            config.allowUnfreePredicate = allowUnfreePredicate;
          };
        in {
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
      # ====================

      # Host configurations
      # ====================
      flake = let
        specialArgs = {
          inherit (inputs) home-manager;
          myLib = import ./lib;
        };
      in {
        nixosConfigurations.desktop = topLevel.withSystem "x86_64-linux"
          (perSystem@{ pkgs, ... }:
            inputs.nixpkgs.lib.nixosSystem {
              inherit specialArgs;
              inherit (perSystem) pkgs;
              modules = [ ./hosts/desktop ];
            });
        darwinConfigurations.laptop = topLevel.withSystem "aarch64-darwin"
          (perSystem@{ pkgs, ... }:
            inputs.darwin.lib.darwinSystem {
              inherit specialArgs;
              inherit (perSystem) pkgs;
              modules = [ ./hosts/laptop ];
            });
      };
      # ====================
    });
}
