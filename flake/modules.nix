{ ... }:
{
  flake = {
    nixosModules.default = import ../modules/system/nixos;
    darwinModules.default = import ../modules/system/darwin;
    homeModules.default = import ../modules/home;
  };
}
