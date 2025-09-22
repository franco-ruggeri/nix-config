{
  description = "Franco Ruggeri's Nix configurations";

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

  outputs = { flake-parts, ... }@inputs:
    # TODO: generalize to more systems... check https://flake.parts
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = 
      let
        system = "aarch64-darwin";
        pkgsUnstable = import inputs.nixpkgs-unstable { 
          inherit system;
          # TODO: use allowUnfreePredicate
          config.allowUnfree = true; 
        };
        overlay = self: super: {
          super-productivity = pkgsUnstable.super-productivity;
          # Warning: The stable Nix package is currently broken.
          # See https://github.com/nixos/nixpkgs/issues/438745
          whatsapp-for-mac = pkgsUnstable.whatsapp-for-mac;
        };
        pkgs = import inputs.nixpkgs { 
          inherit system;
          config.allowUnfree = true; 
          overlays = [ overlay ];
        };
        specialArgs = {
          inherit (inputs) home-manager nixpkgs-unstable;
          myLib = import ./lib { pkgs = inputs.nixpkgs; };
        };
      in {
        nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          inherit specialArgs;
          inherit pkgs;
          modules = [ ./hosts/desktop ];
        };
        darwinConfigurations.laptop = inputs.darwin.lib.darwinSystem {
          inherit system;
          inherit specialArgs;
          inherit pkgs;
          modules = [ ./hosts/laptop ];
        };
      };
      systems = [ "x86_64-linux" "aarch64-darwin" ];
  };
}
