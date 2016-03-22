{ config, pkgs, ... }:
let
  secrets = import ../secrets.nix;
in
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    steam
    google-chrome
    #zeroad openra
    wine
  ];

  hardware = {
    opengl.driSupport = true;
    opengl.driSupport32Bit = true;
    pulseaudio.support32Bit = true;
  };
}
