{ config, myLib, ... }:
{
  myModules.home = {
    username = "erugfra";
    gui.enable = true;
    tui.enable = true;
    homelab.backup.dst = {
      enable = true;
      sourceDataset = "zfs/k8s-backup";
      sourceUser = "franco";
      destinationPath = config.age.secrets.restic-repository-laptop.path;
    };
  };

  age.secrets = myLib.mkSecrets [
    "restic-repository-laptop"
  ];

  # DO NOT change! Used for backward compatibility.
  home.stateVersion = "25.05";
}
