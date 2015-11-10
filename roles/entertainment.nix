{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [ steam ];
  
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;

}
