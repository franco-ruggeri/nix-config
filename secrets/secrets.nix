let
  systemDesktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGvBmqYU3v3bdukVm5xFZN616XwNoHxfwBsJFkJBZslA root@franco-ruggeri-desktop";
  systemLaptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDFNTdpgnu0N02iUzP6uIeWEpqWUGSWUtLykRdEodSDS root@EMB-FQTVQ56V";
  systemServerTurin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICsxrH2bBOvyCL+S4H6hNuk1HbN9hXqJljzpLeUR1v+n root@franco-ruggeri-server-turin";
  homeDesktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDgS2dEYRIrTKF77aI9fxPKKQNAmdHhsJZZ6ee17dThS franco@franco-ruggeri-desktop";
  homeLaptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINkXo7sdR/sgu38eMtxENgbbFHVTeo3UMPtQhhUSS42f erugfra@EMB-FQTVQ56V";
  # TODO: add SSH key
  # homeServerTurin = "";
in
{
  "user-password.age".publicKeys = [ systemDesktop systemServerTurin ];
  "k3s-token.age".publicKeys = [ systemDesktop ];
  "wireguard-desktop-private-key.age".publicKeys = [ systemDesktop ];
  "rclone-nextcloud-password.age".publicKeys = [ homeDesktop ];
  "rclone-gdrive-personal-client-secret.age".publicKeys = [ homeDesktop ];
  "rclone-gdrive-personal-token.age".publicKeys = [ homeDesktop ];
  "rclone-gdrive-pianeta-costruzioni-client-secret.age".publicKeys = [ homeDesktop ];
  "rclone-gdrive-pianeta-costruzioni-token.age".publicKeys = [ homeDesktop ];
  "rclone-onedrive-kth-token.age".publicKeys = [ homeDesktop ];
  "gemini-api-key.age".publicKeys = [
    homeDesktop
    homeLaptop
  ];
}
