{ pkgs, ... }:

{
  imports = [ ../../systems/nixos ];

  users.users.franco-ruggeri = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.zsh;
  };

  home-manager.users.franco-ruggeri = {
    imports = [ ../../users/franco-ruggeri/linux ];

    # DO NOT change! Used for backward compatibility.
    home.stateVersion = "25.05";
  };

  # DO NOT change! Used for backward compatibility.
  system.stateVersion = "25.05";
}
