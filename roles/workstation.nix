{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
 		firefoxWrapper
		gnupg
    (pass.override { x11Support = true; })
    stow
    nodejs
    atom
    ruby
    bundler
    gimp
    inkscape
    transmission
    kde5.kdenlive
    docker
  ];

  nixpkgs.config.packageOverrides = pkgs: with pkgs; {
    firefoxWrapper = wrapFirefox { browser = firefox.override { enableOfficialBranding = true; }; };
  };

  virtualisation.docker.enable = true;

  services.syncthing ={
  	enable = true;
  	user = "jakob";
  };

  services.xserver = {
    enable = true;
    layout = "us";
    displayManager.gdm.enable = false;
    displayManager.slim.enable = true;
    desktopManager.gnome3.enable = true;
    desktopManager.xterm.enable = false;
    desktopManager.default = "gnome3";
    startGnuPGAgent = true;
    synaptics = {
      enable = true;
      accelFactor = "0.005";
      minSpeed = "0.8";
      maxSpeed = "5.0";
      twoFingerScroll = true;
    };
   };

  hardware.pulseaudio.enable = true;
  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      dejavu_fonts
      meslo-lg
      ubuntu_font_family
    ];
  };
}
