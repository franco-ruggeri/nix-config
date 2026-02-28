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
        "nvme"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
    };
    kernelModules = [ "kvm-intel" ];
  };

  networking.hostId = "1c86da41";

  hardware.amdgpu.opencl.enable = true;

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
  };
}
