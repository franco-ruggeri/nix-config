{ pkgs, home-manager, ...}:

{

 imports = [ 
  # TODO: this is gonna be repeated for every host... should be moved to a module (but where? maybe I should import everything here and use users only to define options.)
    home-manager.darwinModules.home-manager 
    ../../systems/darwin ];

  system = {
    primaryUser = "erugfra";

  # DO NOT change! Used for backward compatibility.
  stateVersion = 6;
  };

  users.users.erugfra = {
    home = /Users/erugfra;
      shell = pkgs.zsh;
  };

  home-manager.users.erugfra= {
    imports = [ ../../modules/user/common ../../modules/user/darwin ../../users/franco-ruggeri/common ../../users/franco-ruggeri/darwin ]; 

    home = {
    # DO NOT change! Used for backward compatibility.
    stateVersion = "25.05"; 
    };
  };

}
