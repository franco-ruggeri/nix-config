{ config, ... }:
{
  imports = [
    ../../systems/nixos
    ../../users/franco-ruggeri/linux
  ];

  myModules.system.username = "franco-ruggeri";

  # DO NOT change! Used for backward compatibility.
  system.stateVersion = "25.05";
  home-manager.users.${config.myModules.system.username} = {
    home.stateVersion = "25.05";
  };
}
