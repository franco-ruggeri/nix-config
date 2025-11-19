{
  description = "Franco Ruggeri's Nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    agenix.url = "github:ryantm/agenix";
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      # TODO: temporary workaround for this issue: https://github.com/hraban/mac-app-util/issues/39. Remove when the issue is fixed upstream.
      inputs.cl-nix-lite.url = "github:r4v3n6101/cl-nix-lite/url-fix";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ./flake ];
    };
}
