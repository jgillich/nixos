{ config, lib, pkgs, ... }:

{
  imports = [
    ../roles/common.nix
    ../roles/router.nix
    ../roles/web.nix
  ];

  networking.hostName = "apu";

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "usb_storage" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/84aaf9e9-65f4-4bf1-ba5b-335f08f9214f";
      fsType = "ext4";
    };

  system.stateVersion = "15.09";
  system.autoUpgrade.enable = true;

}
