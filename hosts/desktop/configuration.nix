{ pkgs, ... }:
{
  imports = [ ../../systems/nixos ];

  # TODO: this should actually belong to the user in users/franco-ruggeri, but the username should be a parameter...
  users.users.franco-ruggeri = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
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
