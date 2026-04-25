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
      rsyncPull = {
        enable = true;
        sourceDataset = "zfs/k8s-backup";
        sourceUser = "franco";
        destinationPath = "${config.home.homeDirectory}/Backups/k8s-backup";
      };
    };
  };

  age.secrets = myLib.mkSecrets [
    "restic-repository-laptop"
  ];

  # DO NOT change! Used for backward compatibility.
  home.stateVersion = "25.05";
}
