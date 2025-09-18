{ pkgs, ... }: 

{
      environment.systemPackages =
        [ pkgs.vim
        ];

      nix.settings.experimental-features = "nix-command flakes";

      # DO NOT change! Used for backward compatibility.
      system.stateVersion = 6;

      nixpkgs.hostPlatform = "aarch64-darwin";
    }
