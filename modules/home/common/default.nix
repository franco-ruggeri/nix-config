{
  config,
  pkgs,
  lib,
  agenix,
  ...
}:
{
  imports = [
    ./gui
    ./tui
  ];

  options.myModules.home.username = lib.mkOption {
    type = lib.types.str;
    description = "The username of the main user.";
  };

  config = {
    home = {
      username = config.myModules.home.username;
      packages = [ agenix.packages.${pkgs.system}.default ];
    };

    programs.home-manager.enable = true;

    age.identityPaths = [ "${config.home.homeDirectory}/.ssh/agenix" ];
  };
}
