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
          mkConfig =
            name:
            withSystem "x86_64-linux" (
              perSystem@{ pkgs, ... }:
              inputs.nixpkgs.lib.nixosSystem {
                inherit (perSystem) pkgs;
                specialArgs = mkSpecialArgs pkgs;
                modules = [
                  ../hosts/nixos/${name}
                  config.flake.nixosModules.default
                ];
              }
            );
        in
        {
          desktop = mkConfig "desktop";
        };

      darwinConfigurations =
        let
          mkConfig =
            name:
            withSystem "aarch64-darwin" (
              perSystem@{ pkgs, ... }:
              inputs.darwin.lib.darwinSystem {
                inherit (perSystem) pkgs;
                specialArgs = mkSpecialArgs pkgs;
                modules = [
                  ../hosts/darwin/${name}
                  config.flake.darwinModules.default
                ];
              }
            );
        in
        {
          laptop = mkConfig "laptop";
        };

      homeConfigurations =
        let
          mkConfig =
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
          desktop = mkConfig {
            system = "x86_64-linux";
            path = ../hosts/home/desktop;
          };
          laptop = mkConfig {
            system = "aarch64-darwin";
            path = ../hosts/home/laptop;
          };
          container = mkConfig {
            system = "x86_64-linux";
            path = ../hosts/home/container;
          };
        };
    };
}
