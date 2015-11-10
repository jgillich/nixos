# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  networking.hostName = "nixos";

  system.stateVersion = "15.09";

  boot.loader.gummiboot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  imports =
    [ # Device:
        ./hardware-configuration.nix
      # Roles:
        ./roles/common.nix
        ./roles/workstation.nix
        ./roles/entertainment.nix
    ];


}
