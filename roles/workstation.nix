{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ruby bundler
    rustc cargo
    go
    nodejs
    firefoxWrapper
    gnupg
    pass
    stow
    atom
    gimp
    inkscape
    transmission
    kde5.kdenlive
    docker
    heroku
  ];

  nixpkgs.config.packageOverrides = pkgs: with pkgs; {
    firefoxWrapper = wrapFirefox { browser = firefox.override { enableOfficialBranding = true; }; };

    syncthing =  stdenv.lib.overrideDerivation syncthing (oldAttrs: {
      version = "0.12.2";
    });
  };

  virtualisation.docker.enable = true;

  services.syncthing = {
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
  };

  hardware.pulseaudio.enable = true;

  containers.ghost = {
    config = { config, pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        (import ../pkgs/dotfiles.nix)
        nodejs
        git
        vim
      ];
    };
  };

}
