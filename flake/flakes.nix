{ inputs, withSystem, ... }:
{
  imports = [ inputs.home-manager.flakeModules.home-manager ];

  flake =
    let
      myLib = import ../lib;
      specialArgs = { inherit myLib; };
    in
    {
      nixosConfigurations =
        let
          getFlake =
            path:
            withSystem "x86_64-linux" (
              perSystem@{ pkgs, ... }:
              inputs.nixpkgs.lib.nixosSystem {
                inherit specialArgs;
                inherit (perSystem) pkgs;
                modules = [ path ];
              }
            );
        in
        {
          desktop = getFlake ../hosts/desktop;
        };

      darwinConfigurations =
        let
          getFlake =
            path:
            withSystem "aarch64-darwin" (
              perSystem@{ pkgs, ... }:
              inputs.darwin.lib.darwinSystem {
                inherit specialArgs;
                inherit (perSystem) pkgs;
                modules = [ path ];
              }
            );
        in
        {
          laptop = getFlake ../hosts/laptop;
        };

      homeConfigurations =
        let
          getFlake =
            { system, path }:
            withSystem system (
              perSystem@{ pkgs, ... }:
              inputs.home-manager.lib.homeManagerConfiguration {
                extraSpecialArgs = specialArgs;
                inherit (perSystem) pkgs;
                modules = [
                  path
                  inputs.agenix.homeManagerModules.default
                ];
              }
            );
        in
        {
          desktop = getFlake {
            system = "x86_64-linux";
            path = ../home/desktop;
          };
          laptop = getFlake {
            system = "aarch64-darwin";
            path = ../home/laptop;
          };
        };
    };
}
