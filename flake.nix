{
  description = "Franco Ruggeri's Nix configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # darwin = {
    #   url = "github:LnL7/nix-darwin/release-25.05";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./hosts/desktop ./modules/system ];
    };

    # TODO: set up macbook
    # darwinConfigurations.laptop = {
    # darwin.lib.darwinSystem {
    #   system = "x86_64-darwin";
    #   modules = [
    #     ./hosts/laptop/default.nix
    #     home-manager.darwinModules.home-manager
    #   ];
    # };
    # };

    homeConfigurations.franco-ruggeri =
      home-manager.lib.homeManagerConfiguration {
        modules = [ ./modules/home ];
      };
  };
}
