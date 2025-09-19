{ home-manager, ... }:

{
  imports = [ home-manager.nixosModules.home-manager ];

  users = {
    # TODO: first I need to manage the passwords with agenix
    # mutableUsers = false;
    users = {
      franco-ruggeri = {
        isNormalUser = true;
        description = "Franco Ruggeri";
        extraGroups = [ "networkmanager" "wheel" "docker" ];
      };
    };
  };

  home-manager.users.franco-ruggeri = {
    imports = [ ../../modules/user/common ../../modules/user/linux ];

    # DO NOT change! Used for backward compatibility.
    home.stateVersion = "25.05";
  };
}
