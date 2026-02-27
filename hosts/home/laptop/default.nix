{ config, myLib, ... }:
{
  myModules.home = {
    username = "erugfra";
    gui.enable = true;
    tui.enable = true;
    homelab.backup = {
      enable = true;
      serverAddress = "10.34.0.2";
      resticRepositoryFile = config.age.secrets.restic-repository-laptop.path;
    };
  };

  age.secrets = myLib.mkSecrets [
    "restic-repository-laptop"
  ];

  # DO NOT change! Used for backward compatibility.
  home.stateVersion = "25.05";
}
