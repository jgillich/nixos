{ config, lib, pkgs, ... }:

{
  imports = [
    ../roles/common.nix
    ../roles/workstation.nix
    ../roles/entertainment.nix
  ];

  networking.hostName = "thinkpad";

  boot = {
    loader.gummiboot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "sd_mod" "rtsx_pci_sdmmc" ];
    kernelModules = [ "kvm-intel" "tun" "virtio" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e41cf85e-45ee-4bcf-bf30-1d2432875b0d";
    fsType = "btrfs";
    options = "defaults,compress=lzo,noatime";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0F93-D786";
    fsType = "vfat";
  };

  system.stateVersion = "16.03";
  system.autoUpgrade.enable = true;

  nix.maxJobs = 2;
}
