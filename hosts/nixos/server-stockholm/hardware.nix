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
    };
    kernelModules = [ "kvm-intel" ];
  };

  networking.hostId = "f15005f2";

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/129ce847-9666-478b-975e-af9e6e7a6d18";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/1F31-7C03";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/338b1446-d304-491b-9a1c-d118eef68782"; } ];
}
