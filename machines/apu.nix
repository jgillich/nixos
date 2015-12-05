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

  boot.kernelParams = [ "console=tty0" "console=ttyS0,115200n8" ];

  boot.loader.grub.extraConfig = "serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1; terminal_input serial; terminal_output serial";
  boot.initrd.availableKernelModules = [ "ahci" "ohci_pci" "ehci_pci" "usb_storage" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/7c3cdc13-6d8f-4e69-92bb-264f92376984";
      fsType = "btrfs";
    };

  nix.maxJobs = 2;

  system.stateVersion = "15.09";
  system.autoUpgrade.enable = true;

  services.haveged.enable = true;
}
