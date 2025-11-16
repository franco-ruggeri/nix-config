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
    zfs = {
      forceImportRoot = false;
      extraPools = [ "pool" ];
    };
  };

  networking.hostId = "1c86da41"; # for ZFS

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
    "/mnt/ssd1" = {
      device = "/dev/disk/by-uuid/ab3fb575-6557-479f-9c92-5b6b9717054f";
      fsType = "ext4";
    };
  };
}
