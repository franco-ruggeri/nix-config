{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./gui.nix
    ./tui.nix
  ];

  options.myModules.home.username = lib.mkOption {
    type = lib.types.str;
    description = "The username of the main user.";
  };

  config = {
    home = {
      username = config.myModules.home.username;
      packages = with pkgs; [ agenix ];
    };

    programs.home-manager.enable = true;

    age.identityPaths = [ "${config.home.homeDirectory}/.ssh/agenix" ];
  };
}
