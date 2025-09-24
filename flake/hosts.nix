{ inputs, withSystem, ... }:
{
  flake =
    let
      specialArgs = {
        inherit (inputs) home-manager;
        myLib = import ../lib;
      };
    in
    {
      nixosConfigurations.desktop = withSystem "x86_64-linux" (
        perSystem@{ pkgs, ... }:
        inputs.nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          inherit (perSystem) pkgs;
          modules = [ ../hosts/desktop ];
        }
      );
      darwinConfigurations.laptop = withSystem "aarch64-darwin" (
        perSystem@{ pkgs, ... }:
        inputs.darwin.lib.darwinSystem {
          inherit specialArgs;
          inherit (perSystem) pkgs;
          modules = [ ../hosts/laptop ];
        }
      );
    };
}
