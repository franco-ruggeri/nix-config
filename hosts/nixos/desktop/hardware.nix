{ modulesPath, pkgs, ... }:
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

  # Keyboard and mouse are connected via the USB hub in the monitor. When the
  # monitor is turned off and back on, the USB hub sends malformed USB 3.0
  # signaling during reconnect. This corrupts the xHCI controller's internal
  # state, preventing the keyboard and mouse from enumerating.
  #
  # The fix is to rebind the xHCI PCI device when the USB hub reconnects,
  # which resets the controller to a clean state and allows re-enumeration.
  #
  # Implementation:
  # * udev rule: triggers on reconnect of the USB hub and runs the systemd unit.
  # * systemd unit: resets the controller to a clean state.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ENV{ID_VENDOR_ID}=="0bda", ENV{ID_MODEL_ID}=="0483", ATTR{busnum}=="2", RUN+="${pkgs.systemd}/bin/systemctl start xhci-rebind.service"
  '';
  systemd.services.xhci-rebind = {
    description = "Rebind xHCI controller after monitor USB hub reconnect";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "xhci-rebind" ''
        echo "0000:00:14.0" > /sys/bus/pci/drivers/xhci_hcd/unbind
        sleep 1
        echo "0000:00:14.0" > /sys/bus/pci/drivers/xhci_hcd/bind
      '';
    };
  };
}
