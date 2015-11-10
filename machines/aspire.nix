{ config, lib, pkgs, ... }:

{
  imports =
    [
      ../roles/common.nix
      ../roles/workstation.nix
      ../roles/entertainment.nix
    ];

  networking.hostName = "aspire";

  system.stateVersion = "15.09";

  hardware.enableAllFirmware = true;
  hardware.bumblebee.enable = true;

  boot.loader.gummiboot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/0d549c2b-bf4a-4219-a01d-07c7092ad343";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/B628-0CFD";
      fsType = "vfat";
    };

  #swapDevices = [ { device = "/var/swapfile"; } ];

  nix.maxJobs = 4;


}
