{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  networking.hostId = "178e65e3";

  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/sda";
      useOSProber = true;
    };
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ehci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "sr_mod"
      ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/31cbf14b-5da2-44b8-b1bd-6a4d743c1a73";
    fsType = "ext4";
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/a08de7a5-8f38-4889-af6a-6a9ce7d65ed0"; } ];
}
