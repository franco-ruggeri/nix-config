let
  systemDesktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGvBmqYU3v3bdukVm5xFZN616XwNoHxfwBsJFkJBZslA root@ruggeri-desktop";
  systemLaptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDFNTdpgnu0N02iUzP6uIeWEpqWUGSWUtLykRdEodSDS root@EMB-FQTVQ56V";
  homeDesktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDgS2dEYRIrTKF77aI9fxPKKQNAmdHhsJZZ6ee17dThS franco@ruggeri-desktop";
  homeLaptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINkXo7sdR/sgu38eMtxENgbbFHVTeo3UMPtQhhUSS42f erugfra@EMB-FQTVQ56V";
in
{
  "user-password.age".publicKeys = [ systemDesktop ];
  "k3s-token.age".publicKeys = [ systemDesktop ];
  "wireguard-desktop-private-key.age".publicKeys = [ systemDesktop ];
  "wireguard-desktop-preshared-key.age".publicKeys = [ systemDesktop ];
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
