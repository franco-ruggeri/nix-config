let
  systemDesktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGvBmqYU3v3bdukVm5xFZN616XwNoHxfwBsJFkJBZslA root@franco-ruggeri-desktop";
  systemLaptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDFNTdpgnu0N02iUzP6uIeWEpqWUGSWUtLykRdEodSDS root@EMB-FQTVQ56V";
  systemServerTurin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICsxrH2bBOvyCL+S4H6hNuk1HbN9hXqJljzpLeUR1v+n root@franco-ruggeri-server-turin";
  systemServerStockholm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA2crzCW0fTuKQ6F+a+N50jzLnnMEmSOlmb96t0m1FDB root@franco-ruggeri-server-stockholm";
  homeDesktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDgS2dEYRIrTKF77aI9fxPKKQNAmdHhsJZZ6ee17dThS franco@franco-ruggeri-desktop";
  homeLaptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINkXo7sdR/sgu38eMtxENgbbFHVTeo3UMPtQhhUSS42f erugfra@EMB-FQTVQ56V";
  homeServerTurin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKEN0862srl+E4LYBcxGCkuwzGB9DDOLl4/n/sKkq8+2 franco@franco-ruggeri-server-turin";
  homeServerStockholm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHZZfvbOlw1nxzsvnZA0jhx9GPFTsSB3HyvZScpVp3/w franco@franco-ruggeri-server-stockholm";
in
{
  "user-password-desktop.age".publicKeys = [ systemDesktop ];
  "user-password-server-turin.age".publicKeys = [ systemServerTurin ];
  "user-password-server-stockholm.age".publicKeys = [ systemServerStockholm ];
  "smtp-password.age".publicKeys = [
    systemDesktop
    systemServerTurin
    systemServerStockholm
    homeLaptop
  ];
  "k3s-token-production.age".publicKeys = [ systemDesktop ];
  "k3s-token-staging.age".publicKeys = [ systemServerStockholm ];
  "wireguard-private-key-desktop.age".publicKeys = [ systemDesktop ];
  "wireguard-private-key-server-turin.age".publicKeys = [ systemServerTurin ];
  "wireguard-private-key-server-stockholm.age".publicKeys = [ systemServerStockholm ];
  "restic-repository-laptop.age".publicKeys = [ homeLaptop ];
  "restic-password.age".publicKeys = [
    systemServerStockholm
    systemServerTurin
    homeLaptop
  ];
  "rclone-nextcloud-password.age".publicKeys = [ homeDesktop ];
  "rclone-gdrive-personal-client-secret.age".publicKeys = [ homeDesktop ];
  "rclone-gdrive-personal-token.age".publicKeys = [ homeDesktop ];
  "rclone-gdrive-pianeta-costruzioni-client-secret.age".publicKeys = [ homeDesktop ];
  "rclone-gdrive-pianeta-costruzioni-token.age".publicKeys = [ homeDesktop ];
  "rclone-onedrive-kth-token.age".publicKeys = [ homeDesktop ];
  "gemini-api-key.age".publicKeys = [
    homeDesktop
    homeLaptop
    homeServerTurin
    homeServerStockholm
  ];
}
