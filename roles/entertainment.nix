{ config, pkgs, ... }:
let
  secrets = import ../secrets.nix;
in
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    steam
    #mopidy mopidy-mopify
  ];

  hardware = {
    opengl.driSupport = true;
    opengl.driSupport32Bit = true;
    pulseaudio.enable = true;
    pulseaudio.support32Bit = true;
  };

  #services.mopidy = {
  #  enable = true;
  #  extensionPackages = [ pkgs.mopidy-moped pkgs.mopidy-gmusic ];
  #  configuration = ''
  #    [mpd]
  #    hostname = ::

  #    [gmusic]
  #    username = ${secrets.gmusic.username}
  #    password = ${secrets.gmusic.password}
  #  '';
  #};
}
