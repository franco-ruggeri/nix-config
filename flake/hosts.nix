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
                  inputs.agenix.nixosModules.default
                ];
              }
            );
        in
        {
          desktop = mkConfig "desktop";
          server-turin = mkConfig "server-turin";
          server-stockholm = mkConfig "server-stockholm";
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
                  inputs.agenix.darwinModules.default
                  inputs.mac-app-util.darwinModules.default
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
            { system, name }:
            withSystem system (
              perSystem@{ pkgs, ... }:
              inputs.home-manager.lib.homeManagerConfiguration {
                inherit (perSystem) pkgs;
                extraSpecialArgs = mkSpecialArgs pkgs;
                modules = [
                  ../hosts/home/${name}
                  config.flake.homeModules.default
                  inputs.agenix.homeManagerModules.default
                  inputs.mac-app-util.homeManagerModules.default
                ];
              }
            );
        in
        {
          desktop = mkConfig {
            system = "x86_64-linux";
            name = "desktop";
          };
          laptop = mkConfig {
            system = "aarch64-darwin";
            name = "laptop";
          };
          server = mkConfig {
            system = "x86_64-linux";
            name = "server";
          };
          container-x86 = mkConfig {
            system = "x86_64-linux";
            name = "container";
          };
          container-arm = mkConfig {
            system = "aarch64-linux";
            name = "container";
          };
        };
    };
}
