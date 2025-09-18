{
  description = "Franco Ruggeri's Nix configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
     url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, darwin, ... }@inputs: {
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      modules = [ ./hosts/desktop ./modules/nixos ];
    };

    darwinConfigurations.laptop = darwin.lib.darwinSystem {
      system = "x86_64-darwin";
      modules = [
        ./hosts/laptop ./modules/darwin
      ];
    };

    homeConfigurations.franco-ruggeri =
      home-manager.lib.homeManagerConfiguration {
        modules = [ ./modules/home-manager ];
      };
  };
}
