{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    rustc cargo
    go
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
    gitg
  ];

  nixpkgs.config.packageOverrides = pkgs: with pkgs; {
    firefoxWrapper = wrapFirefox { browser = firefox.override { enableOfficialBranding = true; }; };
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
