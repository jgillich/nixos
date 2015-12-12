{ config, lib, pkgs, ... }:

{
  imports = [
    ../roles/common.nix
    ../roles/workstation.nix
    ../roles/entertainment.nix
  ];

  networking.hostName = "thinkpad";

  hardware.enableAllFirmware = true;

  boot.loader.gummiboot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0d549c2b-bf4a-4219-a01d-07c7092ad343";
    fsType = "btrfs";
    options = "defaults,compress=lzo,noatime";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B628-0CFD";
    fsType = "vfat";
  };

  system.stateVersion = "15.09";
  system.autoUpgrade.enable = true;

  nix.gc.automatic = true;

  services.xserver.synaptics = {
    enable = true;
    accelFactor = "0.005";
    minSpeed = "0.8";
    maxSpeed = "5.0";
    twoFingerScroll = true;
    palmDetect = true;
    additionalOptions =  ''
      Option "SoftButtonAreas"  "50% 0 82% 0 0 0 0 0"
     '';
   };

}
