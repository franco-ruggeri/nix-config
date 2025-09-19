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

  outputs = { nixpkgs, home-manager, darwin, ... }: {
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit home-manager; };
      modules = [ ./hosts/desktop ];
    };

    darwinConfigurations.laptop = darwin.lib.darwinSystem {
      modules = [
        home-manager.darwinModules.home-manager
        ./hosts/laptop
        ./modules/darwin/system
        {
          # TODO: this should be host specific, in hosts/... ??
          users.users.erugfra.home = "/Users/erugfra";
          # TODO: the username should be host-specific, in hosts/... ??
          home-manager.users.erugfra = ./modules/darwin/home;
        }
      ];
    };
  };
}
