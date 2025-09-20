{ pkgs, ... }:

{
  imports = [ ../../systems/darwin ];

  users.users.erugfra = {
    home = /Users/erugfra;
    shell = pkgs.zsh;
  };

  home-manager.users.erugfra = {
    imports = [ ../../users/franco-ruggeri/darwin ];

    home = {
      # DO NOT change! Used for backward compatibility.
      stateVersion = "25.05";
    };
  };

  system = {
    primaryUser = "erugfra";

    # DO NOT change! Used for backward compatibility.
    stateVersion = 6;
  };
}
