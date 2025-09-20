{
  description = "Franco Ruggeri's Nix configurations";

  inputs = {
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

  outputs = { nixpkgs, darwin, ... }@inputs:
    let
      specialArgs = {
        inherit (inputs) home-manager nixpkgs-unstable;
        mylib = import ./lib;
      };
    in {
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [ ./hosts/desktop ];
      };
      darwinConfigurations.laptop = darwin.lib.darwinSystem {
        inherit specialArgs;
        modules = [ ./hosts/laptop ];
      };
    };
}
