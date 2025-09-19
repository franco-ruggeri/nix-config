{ pkgs, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [ "spotify" "discord" ];

  environment.systemPackages = (with pkgs; [ vim discord spotify ]);
  # TODO: need to find a good way to pass nixos-unstable here... doesn't work with flake
  # ++ (let unstable = import <nixos-unstable> { };
  # in with unstable; [ super-productivity ]);
}
