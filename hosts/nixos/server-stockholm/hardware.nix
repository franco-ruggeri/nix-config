{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  networking.hostId = "f15005f2";

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/fafc643c-a709-4d99-963e-7fbdd3361361";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/FFC0-CBE9";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  swapDevices = [ ];
}
