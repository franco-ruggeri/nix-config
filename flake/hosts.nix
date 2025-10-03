{
  config,
  inputs,
  withSystem,
  ...
}:
{
  imports = [ inputs.home-manager.flakeModules.home-manager ];

  flake =
    let
      mkSpecialArgs = pkgs: {
        inherit (inputs) agenix;
        myLib = import ../lib {
          inherit pkgs;
          inherit (pkgs) lib;
        };
      };
    in
    {
      nixosConfigurations =
        let
          getConfig =
            path:
            withSystem "x86_64-linux" (
              perSystem@{ pkgs, ... }:
              inputs.nixpkgs.lib.nixosSystem {
                inherit (perSystem) pkgs;
                specialArgs = mkSpecialArgs pkgs;
                modules = [
                  path
                  config.flake.nixosModules.default
                ];
              }
            );
        in
        {
          desktop = getConfig ../hosts/nixos/desktop;
        };

      darwinConfigurations =
        let
          getConfig =
            path:
            withSystem "aarch64-darwin" (
              perSystem@{ pkgs, ... }:
              inputs.darwin.lib.darwinSystem {
                inherit (perSystem) pkgs;
                specialArgs = mkSpecialArgs pkgs;
                modules = [
                  path
                  config.flake.darwinModules.default
                ];
              }
            );
        in
        {
          laptop = getConfig ../hosts/darwin/laptop;
        };

      homeConfigurations =
        let
          getFlake =
            { system, path }:
            withSystem system (
              perSystem@{ pkgs, ... }:
              inputs.home-manager.lib.homeManagerConfiguration {
                inherit (perSystem) pkgs;
                extraSpecialArgs = mkSpecialArgs pkgs;
                modules = [
                  path
                  config.flake.homeModules.default
                  inputs.agenix.homeManagerModules.default
                ];
              }
            );
        in
        {
          desktop = getFlake {
            system = "x86_64-linux";
            path = ../hosts/home/desktop;
          };
          laptop = getFlake {
            system = "aarch64-darwin";
            path = ../hosts/home/laptop;
          };
          server = getFlake {
            system = "x86_64-linux";
            path = ../hosts/home/server;
          };
        };
    };
}
