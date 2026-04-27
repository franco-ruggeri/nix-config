{ config, myLib, ... }:
{
  myModules.home = {
    username = "erugfra";
    gui.enable = true;
    tui.enable = true;
    homelab.backup.dest = {
      enable = true;
      sourceHost = "10.34.0.2";
      sourceUser = "franco";
      resticRepositoryFile = config.age.secrets.restic-repository-laptop.path;
    };
  };

  age.secrets = myLib.mkSecrets [
    "restic-repository-laptop"
  ];

  # DO NOT change! Used for backward compatibility.
  home.stateVersion = "25.05";
}
