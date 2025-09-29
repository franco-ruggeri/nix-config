let
  publicKeyDesktopSystem = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGvBmqYU3v3bdukVm5xFZN616XwNoHxfwBsJFkJBZslA root@ruggeri-desktop";
  publicKeyDesktopUser = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE2t0NdtOjeuJ2WRxGSA4u9vovoR8Gf6d6BAC77U28Vv franco@ruggeri-desktop";
in
{
  "user-password.age".publicKeys = [ publicKeyDesktopSystem ];
  "rclone-gdrive-personal-client-secret.age".publicKeys = [ publicKeyDesktopUser ];
  "rclone-gdrive-personal-token.age".publicKeys = [ publicKeyDesktopUser ];
}
