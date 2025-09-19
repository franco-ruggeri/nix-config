{
  imports = [ ./hardware.nix ../../modules/common ../../modules/nixos ];

  users.users = {
    franco-ruggeri.description = "Franco Ruggeri";
    roberta-salmeri.description = "Roberta Salmeri";
  };

  # DO NOT change! Used for backward compatibility.
  home-manager.users.franco-ruggeri.home.stateVersion = "25.05";
}
