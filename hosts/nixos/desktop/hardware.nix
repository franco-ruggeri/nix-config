{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usb_storage"
      "usbhid"
      "sd_mod"
    ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/29a0ee53-d35d-46a6-995d-8dc45df233ad";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/09B0-8741";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
    "/var/lib/rancher/k3s/storage" = {
      device = "/dev/disk/by-uuid/a95ee5bb-3a48-4c13-8921-7acbc80c11ba";
      fsType = "ext4";
    };
  };
}
