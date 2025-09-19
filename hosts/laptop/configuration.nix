# TODO: add machine-specific configuration of macos
{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.vim ];

  services.karabiner-elements.enable = true;
  system.primaryUser = "erugfra"; # TODO: this is machine specific

  nix.settings.experimental-features = "nix-command flakes";

  # DO NOT change! Used for backward compatibility.
  system.stateVersion = 6;

  nixpkgs.hostPlatform = "aarch64-darwin";
}
