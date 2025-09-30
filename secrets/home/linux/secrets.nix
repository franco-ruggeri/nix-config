let
  publicKeyDesktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDgS2dEYRIrTKF77aI9fxPKKQNAmdHhsJZZ6ee17dThS franco@ruggeri-desktop";
in
{
  "rclone-gdrive-personal-client-secret.age".publicKeys = [ publicKeyDesktop ];
  "rclone-gdrive-personal-token.age".publicKeys = [ publicKeyDesktop ];
  "rclone-gdrive-pianeta-costruzioni-client-secret.age".publicKeys = [ publicKeyDesktop ];
  "rclone-gdrive-pianeta-costruzioni-token.age".publicKeys = [ publicKeyDesktop ];
  "rclone-onedrive-kth-token.age".publicKeys = [ publicKeyDesktop ];
}
