let
  publicKeyDesktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGvBmqYU3v3bdukVm5xFZN616XwNoHxfwBsJFkJBZslA root@ruggeri-desktop";
in
{
  "user-password.age".publicKeys = [ publicKeyDesktop ];
}
