# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the gummiboot efi boot loader.
  boot.loader.gummiboot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;  # Enables wireless support via wpa_supplicant.

  hardware.trackpoint.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;

  virtualisation.docker.enable = true;  

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    # basic
    vim wget sudo pass syncthing
    
    # dev
    git nodejs atom ruby bundler

    # games
    steam
    
    # desktop
    firefoxWrapper gimp inkscape kde5.kdenlive transmission
  ];

  nixpkgs.config = {
     allowUnfree = true;
     packageOverrides = pkgs: rec {
       #firefox = pkgs.firefox.override {
       #  enableOfficialBranding = true;
       #};
     };
   };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.syncthing.enable = true;
  services.printing.enable = true;

   services.xserver = {
    enable = true;
    layout = "us";
    displayManager.gdm.enable = false;
    displayManager.slim.enable = true; 
    desktopManager.gnome3.enable = true;
    desktopManager.default = "gnome3";
    
  };
 
 # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.jakob = {
    isNormalUser = true;
    uid = 1000;
    createHome = true;
    home = "/home/jakob";
    extraGroups = [ "wheel" "disk" "cdrom" "docker" ];
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "15.09";

}

