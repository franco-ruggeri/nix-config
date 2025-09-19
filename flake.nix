{
  description = "Franco Ruggeri's Nix configurations";

  # NOTE: I need to use nix-darwin unstable for this PR: https://github.com/nix-darwin/nix-darwin/pull/1396
  # nix-darwin unstable requires nixpkgs-unstable, and home-manager must follow nixpkgs. So, everything unstable for darwin, for now.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    darwin = {
     url = "github:nix-darwin/nix-darwin/master";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, home-manager, home-manager-unstable, darwin, ... }@inputs: {
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      modules = [ 
        home-manager.nixosModules.home-manager
        ./hosts/desktop 
        ./modules/nixos 
                  {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.franco-ruggeri = ./modules/home;
        }
      ];
    };

    darwinConfigurations.laptop = darwin.lib.darwinSystem {
      modules = [
        home-manager-unstable.darwinModules.home-manager
        ./hosts/laptop 
        ./modules/darwin/system
        {
          # TODO: this should be host specific, in hosts/... ??
          users.users.erugfra.home = "/Users/erugfra";
            # home-manager.useGlobalPkgs = true;
            # home-manager.useUserPackages = true;
            # TODO: the username should be host-specific, in hosts/... ??
            home-manager.users.erugfra = ./modules/darwin/home;
        }
      ];
    };
  };
}
